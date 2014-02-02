---
layout: post
title:  "Hadoop的简单控制台log分析"
date:   2013-10-11 10:00:00
category: geek
tags: hadoop map-reduce
---

<p class="excerpt">
<!--excerpt-->
以一个wordcount为例，详细讲解控制台输出的log信息，并通过改变jobconf的参数观察map reduce行为的变化。
<!--excerpt-->
</p>

本次的实验的环境为Centos6 + java6 + hadoop1.2.1，并且是运行在local模式。关于环境的配置这里就不加赘述了。

首先把最最简单的代码贴上来，这是本次实验代码的主体。
{% highlight java %}
import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

public class WordCount extends Configured implements Tool {

	public static class TokenizerMapper extends
			Mapper<Object, Text, Text, IntWritable> {

		private final static IntWritable one = new IntWritable(1);
		private Text word = new Text();

		public void map(Object key, Text value, Context context)
				throws IOException, InterruptedException {
			StringTokenizer itr = new StringTokenizer(value.toString());
			while (itr.hasMoreTokens()) {
				String token = itr.nextToken();
				if (token.isEmpty()) {
					continue;
				}
				word.set(token);
				context.write(word, one);
			}
		}
	}

	public static class IntSumReducer extends
			Reducer<Text, IntWritable, Text, IntWritable> {
		private IntWritable result = new IntWritable();

		public void reduce(Text key, Iterable<IntWritable> values,
				Context context) throws IOException, InterruptedException {
			int sum = 0;
			for (IntWritable val : values) {
				sum += val.get();
			}
			result.set(sum);
			context.write(key, result);
		}
	}


	public int run(String[] args) throws Exception {
		Configuration conf = new Configuration();
		String[] otherArgs = new GenericOptionsParser(conf, args)
				.getRemainingArgs();
		if (otherArgs.length != 2) {
			System.err.println("Usage: wordcount <in> <out>");
			System.exit(2);
		}

		Job job = new Job(conf, "word count");
		job.setJarByClass(WordCount.class);
		job.setMapperClass(TokenizerMapper.class);
		job.setCombinerClass(IntSumReducer.class);
		job.setReducerClass(IntSumReducer.class);
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(IntWritable.class);
		FileInputFormat.addInputPath(job, new Path(otherArgs[0]));
		FileOutputFormat.setOutputPath(job, new Path(otherArgs[1]));
		System.exit(job.waitForCompletion(true) ? 0 : 1);
		return 0;
	}


	public static void main(String[] args) throws Exception {
		ToolRunner.run(new WordCount(), args);
	}
}
{% endhighlight %}

首先我们来看以上这段代码的控制台结果，对应的解释嵌在结果里面。
{% highlight java %}
Oct 6, 2013 2:17:01 PM org.apache.hadoop.util.NativeCodeLoader <clinit>
WARNING: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Oct 6, 2013 2:17:01 PM org.apache.hadoop.mapred.JobClient copyAndConfigureFiles
WARNING: No job jar file set.  User classes may not be found. See JobConf(Class) or JobConf#setJar(String).
Oct 6, 2013 2:17:01 PM org.apache.hadoop.mapreduce.lib.input.FileInputFormat listStatus
//19是hadoop计算map reduce的时候总共要处理的文件的数量，也就是FileInputFormat.addInputPath指定的文件夹里面的文件数量（如果指定的是文件夹的话）。
INFO: Total input paths to process : 19
Oct 6, 2013 2:17:01 PM org.apache.hadoop.io.compress.snappy.LoadSnappy <clinit>
WARNING: Snappy native library not loaded
Oct 6, 2013 2:17:02 PM org.apache.hadoop.mapred.JobClient monitorAndPrintJob
//1463375898_0001是本次map reduce的job_id号
INFO: Running job: job_local1463375898_0001
Oct 6, 2013 2:17:02 PM org.apache.hadoop.mapred.LocalJobRunner$Job run
INFO: Waiting for map tasks
Oct 6, 2013 2:17:02 PM org.apache.hadoop.mapred.LocalJobRunner$Job$MapTaskRunnable run
//这里开始跑第一个map，这里的attempt_local1463375898_0001_m_000000_0的意思是
//在jobid 1463375898_0001中的第0个map的第0次尝试。
INFO: Starting task: attempt_local1463375898_0001_m_000000_0
Oct 6, 2013 2:17:02 PM org.apache.hadoop.util.ProcessTree isSetsidSupported
INFO: setsid exited with exit code 0
Oct 6, 2013 2:17:02 PM org.apache.hadoop.mapred.Task initialize
INFO:  Using ResourceCalculatorPlugin : org.apache.hadoop.util.LinuxResourceCalculatorPlugin@48e61a35
Oct 6, 2013 2:17:02 PM org.apache.hadoop.mapred.MapTask runNewMapper
//显示我们将要处理的文件
INFO: Processing split: file:/home/coolmore/workspace/eclipse/HadoopStudy/data/in/hadoop_1.2.1.xml:0+3686382
Oct 6, 2013 2:17:02 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer <init>
//一些mapreduce的参数
//io.sort.mb  指的是每个map存储中间结果的内存的最大size。如果超过这个值，数据就会spill到磁盘。
INFO: io.sort.mb = 100
Oct 6, 2013 2:17:02 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer <init>
//这里796917760=996147200*0.8。 0.8指的是参数io.sort.spill.percent的值。
//这个值的意思是如果io.sort.mb为100MB，那么当内存中的数据达到80MB时就会开始把数据spill到磁盘，
//并且在spill之前可能会执行combiner将结果集减小。
//在此之后会一边spill数据一边填充数据，类似于一个不断的生产和消费的过程。
INFO: data buffer = 796917760/996147200
Oct 6, 2013 2:17:02 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer <init>
//2621440=3276800*0.8
INFO: record buffer = 2621440/3276800
Oct 6, 2013 2:17:02 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer flush
//这里第一个map的数据在内存中足够放下，所以不用做中途的spill，所以结果直接flush出来，当然也是flush到磁盘上。在flush之前要在内存中进行sort操作。
INFO: Starting flush of map output
Oct 6, 2013 2:17:03 PM org.apache.hadoop.mapred.JobClient monitorAndPrintJob
INFO:  map 0% reduce 0%
Oct 6, 2013 2:17:03 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer sortAndSpill
INFO: Finished spill 0
//第一个map结束。
Oct 6, 2013 2:17:03 PM org.apache.hadoop.mapred.Task done
INFO: Task:attempt_local1463375898_0001_m_000000_0 is done. And is in the process of commiting
Oct 6, 2013 2:17:03 PM org.apache.hadoop.mapred.LocalJobRunner$Job statusUpdate
INFO:
Oct 6, 2013 2:17:03 PM org.apache.hadoop.mapred.Task sendDone
INFO: Task 'attempt_local1463375898_0001_m_000000_0' done.
Oct 6, 2013 2:17:03 PM org.apache.hadoop.mapred.LocalJobRunner$Job$MapTaskRunnable run
INFO: Finishing task: attempt_local1463375898_0001_m_000000_0
Oct 6, 2013 2:17:03 PM org.apache.hadoop.mapred.LocalJobRunner$Job$MapTaskRunnable run
//这里开始跑第二个map，这里的attempt_local1463375898_0001_m_000001_0的意思是
//在jobid attempt_local1463375898_0001中的第1个map的第0次尝试。接下来的步骤都是大同小异的，所以略过。
INFO: Starting task: attempt_local1463375898_0001_m_000001_0
。。。。。。
。。。。。。
。。。。。。
//最后一个map执行成功了。
INFO: Finishing task: attempt_local1463375898_0001_m_000018_0
Oct 6, 2013 2:17:12 PM org.apache.hadoop.mapred.LocalJobRunner$Job run
//所有的map执行成功了
INFO: Map task executor complete.
Oct 6, 2013 2:17:12 PM org.apache.hadoop.mapred.Task initialize
INFO:  Using ResourceCalculatorPlugin : org.apache.hadoop.util.LinuxResourceCalculatorPlugin@79884a40
Oct 6, 2013 2:17:12 PM org.apache.hadoop.mapred.LocalJobRunner$Job statusUpdate
INFO:
Oct 6, 2013 2:17:12 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
//这里其实到了reduce的部分，之前的19个map会生成19个文件，这些文件分别会被送到reduce中处理，并且这些文件都是已经排好序了。
//这里有一个参数很重要也就是io.sort.factor，意思是reduce和mapper做归并排序的最多处理的文件，本例中是10。
//因为我们总共有19个文件，所以reducer要先把这19个文件归并成10个。
INFO: Merging 19 sorted segments
Oct 6, 2013 2:17:12 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 10 intermediate segments out of a total of 19
Oct 6, 2013 2:17:12 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
//10个文件总大小为7.9MB左右。
INFO: Down to the last merge-pass, with 10 segments left of total size: 7896329 bytes
Oct 6, 2013 2:17:12 PM org.apache.hadoop.mapred.LocalJobRunner$Job statusUpdate
INFO:
Oct 6, 2013 2:17:12 PM org.apache.hadoop.mapred.Task done
//jobid为1463375898_0001的第1个reducer的第1次尝试完成了。
INFO: Task:attempt_local1463375898_0001_r_000000_0 is done. And is in the process of commiting
Oct 6, 2013 2:17:12 PM org.apache.hadoop.mapred.LocalJobRunner$Job statusUpdate
INFO:
Oct 6, 2013 2:17:12 PM org.apache.hadoop.mapred.Task commit
INFO: Task attempt_local1463375898_0001_r_000000_0 is allowed to commit now
Oct 6, 2013 2:17:12 PM org.apache.hadoop.mapreduce.lib.output.FileOutputCommitter commitTask
//将结果输出
INFO: Saved output of task 'attempt_local1463375898_0001_r_000000_0' to /home/coolmore/workspace/eclipse/HadoopStudy/data/out
Oct 6, 2013 2:17:12 PM org.apache.hadoop.mapred.LocalJobRunner$Job statusUpdate
INFO: reduce > reduce
Oct 6, 2013 2:17:12 PM org.apache.hadoop.mapred.Task sendDone
INFO: Task 'attempt_local1463375898_0001_r_000000_0' done.
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.JobClient monitorAndPrintJob
//进度条满了
INFO:  map 100% reduce 100%
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.JobClient monitorAndPrintJob
INFO: Job complete: job_local1463375898_0001
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
//把所有的counter的数据打出来把所有的counter的数据打出来，counter分成几个组，有
//FileInput Format counter
//FileOutput Format Counters
//MapReduce task counters
//Filesystem counters
//Job counters 几大类。
INFO: Counters: 20
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:   File Output Format Counters
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Bytes Written=629401
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:   File Input Format Counters
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Bytes Read=52879822
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:   FileSystemCounters
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     FILE_BYTES_READ=672008497
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     FILE_BYTES_WRITTEN=101705449
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:   Map-Reduce Framework
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Map output materialized bytes=7896423
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Map input records=1252054
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Reduce shuffle bytes=0
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Spilled Records=784653
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Map output bytes=63190860
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     CPU time spent (ms)=0
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Total committed heap usage (bytes)=37932826624
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Combine input records=4020645
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     SPLIT_RAW_BYTES=2654
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Reduce input records=322311
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Reduce input groups=24731
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Combine output records=322311
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Physical memory (bytes) snapshot=0
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Reduce output records=24731
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Virtual memory (bytes) snapshot=0
Oct 6, 2013 2:17:13 PM org.apache.hadoop.mapred.Counters log
INFO:     Map output records=4020645
{% endhighlight %}

为了看得方便，我们把所有的counter都列出来。

####FileInputFormat task counters:

* Bytes Read=52879822(BYTES_READ)
读取的input的数据文件的总大小为53MB左右。


####FileOputFormat task counters:

* Bytes Written=629401(BYTES_WRITTEN)
最终在HDFS生成的文件的大小为629KB左右。


####FileSystemCounters:

* FILE_BYTES_READ=672008497
累计读取本地磁盘的文件数据大小，map和reduce端有排序和归并，这些都需要占用io。
* FILE_BYTES_WRITTEN=101705449
累计写入本地磁盘的文件数据大小。

####Map-Reduce Framework:

* Map input records=1252054(MAP_INPUT_RECORDS)
Map的输入的record数量，每次调用map函数的时候就会记一下。你可能奇怪Map input records哪里去了，其实它就是BYTES_READ。
* Map output records=4020645(MAP_OUTPUT_RECORDS)
Map输出的records的数量，每次调用collect方法就会记录一下。
* Map output bytes=63190860(MAP_OUTPUT_BYTES)
非压缩的map的输出总大小，每次调用collect方法就会记录一下。
* Combine input records=4020645(COMBINE_INPUT_RECORDS)
在中间操作combiner的处理的record的数量，这里Combine input records=Map output records。
自然Combine input bytes=Map output bytes
* Combine output records=322311(COMBINE_OUTPUT_RECORDS)
我们看到Combine input records=4020645，而Combine output records之后是322311，数据量大量减少了，提高了性能。
* Map output materialized bytes=7896423(MAP_OUTPUT_MATERIALIZED_BYTES)
据官方文档是说map真正输出到磁盘的文件的大小，如果map输出的文件是压缩的，那么改值就是压缩之后的值。
这里的值比Map output bytes小是因为combiner减小了数据量。
* Reduce input records=322311(REDUCE_INPUT_RECORDS)
Reducer所接受到的所有的record的数量，包含那些key是相同的record，每次迭代values的时候就会记一下。
这里 Combine output 和 Reduce input的值是一样的。
* Reduce input groups=24731(REDUCE_INPUT_GROUPS)
Reducer所接受到的所有的key的distinct值的数量，每次调用reduce方法就会记一下。
* Reduce output records=24731(REDUCE_OUTPUT_RECORDS)
这里Reduce output records=Reduce input groups， 因为我们没有做过滤。
* Spilled Records=784653(SPILLED_RECORDS)
在map和reduce过程中splill到磁盘的record的数量。

