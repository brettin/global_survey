# Attempt to assemble whole plasmids from a metagenomic sample (fasta file)
import sys, argparse, time
import numpy as np

def main():
    parser = argparse.ArgumentParser(description='Assemble a plasmid from a starting sequence and fasta file of reads')
    parser.add_argument("start_file", type=str, help="File containing starting sequence(s) for targeted assembly")
    parser.add_argument("read_file",  type=str, help="FASTA file of reads to be searched/assembled")
    parser.add_argument("out_file",   type=str, help="Base output filename for coverage data and final assembly files")
    parser.add_argument("-o", "--overlap", dest="overlap", default=60, type=int, help="Length of match to search for")
    parser.add_argument("-c", "--coverage", dest="coverage", default=1, type=int, help="Minimum coverage for adding to assembled sequence")
    parser.add_argument("-p", "--paired", dest="paired", type=str, help="Paired read file")
    args = parser.parse_args()

    start_time = time.time()

    with open(args.start_file, "r") as in_file:
        all_lines = in_file.readlines()

    start_seq_f = {}
    start_seq_r = {}
    read_dict = {}
    kmer_dict = {}
    kmer_len = args.overlap
    read_files = [args.read_file]
    NT_dict = {"A":"T","C":"G","G":"C","T":"A"}

    for i in range(0,len(all_lines),2):
        seq = all_lines[i+1].rstrip().upper()
        rev_seq = "".join([NT_dict[x] for x in reversed(seq)])
        start_seq_f[all_lines[i].rstrip()] = seq
        start_seq_r[all_lines[i].rstrip()] = rev_seq

        if len(seq) < kmer_len:
            print("Overlap length changed to %d because of minimum start sequence length." % (len(seq)))
            kmer_len = len(seq)

    if args.paired:
        read_files.append(args.paired)

    read_lines = []

    for filename in read_files:
        with open(filename, "r") as read_file:
            read_lines.extend(read_file.readlines())

    for i in range(1, len(read_lines), 2):
        read = read_lines[i].rstrip().upper()
    
        if "N" not in read:
            read_dict.setdefault(read, 0)
            read_dict[read] += 1
            rev_read = "".join([NT_dict[x] for x in reversed(read)])
            read_dict.setdefault(rev_read, 0)
            read_dict[rev_read] += 1

    for read in read_dict.keys():
        for k in range(len(read)-kmer_len):
            kmers = read[k:k+kmer_len] + " " + read[k+kmer_len]
            kmer_dict.setdefault(kmers, 0)
            kmer_dict[kmers] += read_dict[read]

    read_time = time.time()
    print("Dictionary containing %d unique kmers built in %0.2f seconds." % (len(kmer_dict.keys()), read_time - start_time))

    out_file = open(args.out_file + ".fa", "w")

    final_seq_f = build_seq(start_seq_f, kmer_dict, kmer_len, args.coverage, args.out_file)
    final_seq_r = build_seq(start_seq_r, kmer_dict, kmer_len, args.coverage, args.out_file)

    print("Assembly finished in %0.2f seconds." % (time.time()-read_time))

    for n_seq in final_seq_f.keys():
        rev_seq = "".join([NT_dict[x] for x in reversed(final_seq_r[n_seq])])
        out_file.write(n_seq + "\n")
        out_file.write(rev_seq[:-kmer_len])
        out_file.write(final_seq_f[n_seq] + "\n\n")

    out_file.close()



def build_seq(start_seq, kmer_dict, overlap, coverage, out_name):
    NTs = ["A", "C", "G", "T"]
    final_seq = {}
    cov_file = out_name + ".cov"
    
    coverage_out = open(cov_file, "w")
    coverage_out.write("kmer\tNT_coverage\tTotal_coverage\n")

    for seq in start_seq.keys():
        assemble_seq = start_seq[seq]
        curr_cov = coverage

        while curr_cov >= coverage:
            curr_cov = 0
            NT_cts = []

            for NT in NTs:
                kmer = assemble_seq[-overlap:] + " " + NT

                try:
                    NT_cts.append(kmer_dict[kmer])
                    curr_cov += kmer_dict[kmer]
                except:
                    NT_cts.append(0)

            if max(NT_cts) > 0.5*curr_cov:
                assemble_seq += NTs[np.argmax(NT_cts)]
                coverage_out.write(assemble_seq[-overlap:] + "\t" + str(max(NT_cts)) + "\t" + str(curr_cov) + "\n")
            else:
                coverage_out.write("Assembly ended due to divergent sequence.\n")
                break

            if assemble_seq[:-overlap].find(assemble_seq[-overlap:]) > -1:
                coverage_out.write("Assembly ended due to unresolved repeat region.\n")
                break

        final_seq[seq] = assemble_seq

    return final_seq



if __name__ == "__main__":
    main()
