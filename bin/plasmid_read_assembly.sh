start=$(date)
echo "start: $start"

function_to_fork() {
  top -b -n 240 -d 3 -u brettin > $$.top
}
function_to_fork &
child_pid=$!


python plasmid_read_assembly.py start_seq_SRR3984929.txt SRR3984929_1_short.fasta SRR3984929_assembly -p=SRR3984929_2_short.fasta

stop=$(date)
echo "stop: $stop"

kill -9 $child_pid
