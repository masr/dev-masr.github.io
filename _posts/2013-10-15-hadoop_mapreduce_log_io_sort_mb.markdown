---
layout: post
title:  "Hadoop的简单控制台log分析之io.sort.mb"
date:   2013-10-15 09:00:00
category: geek
tags: hadoop map-reduce
---



<p class="excerpt">
<!--excerpt-->
这次在代码中修改io.sort.factor，再观察hadoop的行为。
<!--excerpt-->
</p>

上一篇文章的地址是[here][last post link]。请先阅读这一篇文章。

`io.sort.mb`的意思是map用来排序数据的占用的内存的大小，默认值是100MB。之前因为数据量，所以没有spill到磁盘的情况，这次把内存改到10MB再看看效果。
对应的代码是
{% highlight java %}
conf.set("io.sort.mb", "10");
{% endhighlight %}

首先我们来看以上这段代码的控制台结果，对应的解释嵌在结果里面。
{% highlight java %}
。。。。。。
。。。。。。
。。。。。。
//因为打出的log实在太多，所以截取了。这是第12个map。
NFO: Starting task: attempt_local1065779629_0001_m_000012_0
Oct 15, 2013 10:03:05 AM org.apache.hadoop.mapred.Task initialize
INFO:  Using ResourceCalculatorPlugin : org.apache.hadoop.util.LinuxResourceCalculatorPlugin@75d252d
Oct 15, 2013 10:03:05 AM org.apache.hadoop.mapred.MapTask runNewMapper
INFO: Processing split: file:/home/coolmore/workspace/eclipse/HadoopStudy/data/in/hadoop_0.18.1.xml:0+1883089
Oct 15, 2013 10:03:05 AM org.apache.hadoop.mapred.MapTask$MapOutputBuffer <init>
//该值已经被我们设置成了3MB。
INFO: io.sort.mb = 3
Oct 15, 2013 10:03:05 AM org.apache.hadoop.mapred.MapTask$MapOutputBuffer <init>
//2988448 * 0.8 = 2390758
INFO: data buffer = 2390758/2988448
Oct 15, 2013 10:03:05 AM org.apache.hadoop.mapred.MapTask$MapOutputBuffer <init>
INFO: record buffer = 7864/9830
Oct 15, 2013 10:03:05 AM org.apache.hadoop.mapred.MapTask$MapOutputBuffer collect
INFO: Spilling map output: record full = true
Oct 15, 2013 10:03:05 AM org.apache.hadoop.mapred.MapTask$MapOutputBuffer startSpill
INFO: bufstart = 0; bufend = 124118; bufvoid = 2988448
Oct 15, 2013 10:03:05 AM org.apache.hadoop.mapred.MapTask$MapOutputBuffer startSpill
INFO: kvstart = 0; kvend = 7864; length = 9830
Oct 15, 2013 10:03:05 AM org.apache.hadoop.mapred.MapTask$MapOutputBuffer sortAndSpill
//spill第一个文件
INFO: Finished spill 0
Oct 15, 2013 10:03:05 AM org.apache.hadoop.mapred.MapTask$MapOutputBuffer collect
INFO: Spilling map output: record full = true
Oct 15, 2013 10:03:05 AM org.apache.hadoop.mapred.MapTask$MapOutputBuffer startSpill
INFO: bufstart = 124118; bufend = 258921; bufvoid = 2988448
Oct 15, 2013 10:03:05 AM org.apache.hadoop.mapred.MapTask$MapOutputBuffer startSpill
INFO: kvstart = 7864; kvend = 5897; length = 9830
Oct 15, 2013 10:03:05 AM org.apache.hadoop.mapred.MapTask$MapOutputBuffer sortAndSpill
//spill第二个文件
INFO: Finished spill 1
。。。。。。
。。。。。。
。。。。。。
//spill第19个文件
INFO: Finished spill 18
Oct 15, 2013 10:03:06 AM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 19 sorted segments
Oct 15, 2013 10:03:06 AM org.apache.hadoop.mapred.Merger$MergeQueue merge
//把19个文件merge成10个。这是由io.sort.factor决定的。指的是进行归并排序的时候最多处理的文件个数。
//因为最终一个map输出一个带partition的大文件，所以这10个大文件是用来做进一步的合并的。
INFO: Merging 10 intermediate segments out of a total of 19
Oct 15, 2013 10:03:06 AM org.apache.hadoop.mapred.Merger$MergeQueue merge
//最终生成出来的一个文件文件达到了500KB。
INFO: Down to the last merge-pass, with 10 segments left of total size: 500067 bytes
Oct 15, 2013 10:03:06 AM org.apache.hadoop.mapred.Task done
INFO: Task:attempt_local1065779629_0001_m_000012_0 is done. And is in the process of commiting
。。。。。。
。。。。。。
。。。。。。
//map已经做完了。
INFO:  map 100% reduce 0%
Oct 15, 2013 10:03:13 AM org.apache.hadoop.mapred.Task initialize
INFO:  Using ResourceCalculatorPlugin : org.apache.hadoop.util.LinuxResourceCalculatorPlugin@d522de2
Oct 15, 2013 10:03:13 AM org.apache.hadoop.mapred.LocalJobRunner$Job statusUpdate
INFO:
Oct 15, 2013 10:03:13 AM org.apache.hadoop.mapred.Merger$MergeQueue merge
//这里其实到了reduce的部分，之前的19个map会生成19个文件，这些文件分别会被送到reduce中处理，并且这些文件都是已经排好序了。
//这里有一个参数很重要也就是io.sort.factor，意思是reduce和mapper做归并排序的最多处理的文件，本例中是10。
//因为我们总共有19个文件，所以reducer要先把这19个文件归并成10个。
INFO: Merging 19 sorted segments
Oct 15, 2013 10:03:14 AM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 10 intermediate segments out of a total of 19
Oct 15, 2013 10:03:14 AM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Down to the last merge-pass, with 10 segments left of total size: 7896329 bytes
Oct 15, 2013 10:03:14 AM org.apache.hadoop.mapred.LocalJobRunner$Job statusUpdate
INFO:
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Task done
INFO: Task:attempt_local1065779629_0001_r_000000_0 is done. And is in the process of commiting
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.LocalJobRunner$Job statusUpdate
INFO:
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Task commit
INFO: Task attempt_local1065779629_0001_r_000000_0 is allowed to commit now
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapreduce.lib.output.FileOutputCommitter commitTask
INFO: Saved output of task 'attempt_local1065779629_0001_r_000000_0' to /home/coolmore/workspace/eclipse/HadoopStudy/data/out
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.LocalJobRunner$Job statusUpdate
INFO: reduce > reduce
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Task sendDone
INFO: Task 'attempt_local1065779629_0001_r_000000_0' done.
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.JobClient monitorAndPrintJob
INFO:  map 100% reduce 100%
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.JobClient monitorAndPrintJob
INFO: Job complete: job_local1065779629_0001
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO: Counters: 20
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:   File Output Format Counters
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Bytes Written=629401
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:   File Input Format Counters
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Bytes Read=52879822
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:   FileSystemCounters
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     FILE_BYTES_READ=980198949
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     FILE_BYTES_WRITTEN=409895781
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:   Map-Reduce Framework
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Map output materialized bytes=7896423
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Map input records=1252054
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Reduce shuffle bytes=0
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Spilled Records=1961335
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Map output bytes=63190860
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     CPU time spent (ms)=0
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Total committed heap usage (bytes)=3200450560
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Combine input records=4715126
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     SPLIT_RAW_BYTES=2654
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Reduce input records=322311
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Reduce input groups=24731
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Combine output records=1016792
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Physical memory (bytes) snapshot=0
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Reduce output records=24731
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Virtual memory (bytes) snapshot=0
Oct 15, 2013 10:03:15 AM org.apache.hadoop.mapred.Counters log
INFO:     Map output records=4020645
{% endhighlight %}

运行完毕，发现运行所需的时间要远远大于前一次运行的时间。
为了看得方便，我们把所有的counter都列出来。这里我们会将counter的值和上一次的结果[here][last post link]做对比。

####FileInputFormat task counters:

* Bytes Read=52879822(BYTES_READ)
这个数字和前面一篇文章的数字相同，因为input没有变化。


####FileOputFormat task counters:

* Bytes Written=629401(BYTES_WRITTEN)
这个数字和前面一篇文章的数字相同，因为output没有变化。


####FileSystemCounters:

* FILE_BYTES_READ=980198949
之前的数字是672008497，增加的原因是因为内存变小之后，在map进行spill的时候combiner的效率就降低了。导致了Map output bytes变大了。所以读取的也变大了。
* FILE_BYTES_WRITTEN=409895781
之前的数据是101705449，io增加了不少。

####Map-Reduce Framework:

* Map input records=1252054(MAP_INPUT_RECORDS)
数值不变。
* Map output records=4020645(MAP_OUTPUT_RECORDS)
数值不变。
* Map output bytes=63190860(MAP_OUTPUT_BYTES)
数值不变。
* Combine input records=4715126(COMBINE_INPUT_RECORDS)
之前的数据是4020645。这里要多一点是因为map内存spill之前要做一次combine，然后最后归并成一个大文件的时候又要做一次combine。
而前一次的实验是没有归并的过程的，也就是说这一次的combiner在归并文件的时候多做了几次。
但是这里比较tricky的地方是我们也不知道combiner到底执行了几次，这是由hadoop运行时决定的，可能会考虑性能或者io的因素，这里也只是大概的看到一个趋势的变化。
就是combiner调用的次数变多了。
* Combine output records=1016792(COMBINE_OUTPUT_RECORDS)
原来的数据是322311。因为内存变小，每次combine的“压缩比”其实很低，导致了combiner产生的数据变多了（其实应该是产生的越少越好）。
* Map output materialized bytes=7896423(MAP_OUTPUT_MATERIALIZED_BYTES)
数值不变。最终合并成的大文件其实是不变的。
* Reduce input records=322311(REDUCE_INPUT_RECORDS)
数值不变。
* Reduce input groups=24731(REDUCE_INPUT_GROUPS)
数值不变。
* Reduce output records=24731(REDUCE_OUTPUT_RECORDS)
数值不变。
* Spilled Records=1961335(SPILLED_RECORDS)
原来的数字是784653，这里多出来的部分就是combiner效率降低导致的那部分。

我们具体阐述一下到底减小memory对性能会有什么影响。首先对于map而言，读取input文件这一部份是不变的，并且执行map函数这一部分也是一样的。
变的是当内存被撑满的时候的动作，当内存被撑满时，map会把数据spill到磁盘，在spill的时候会做一次combiner的操作。试想，一个是对100MB的数据做combine，
一个是对3MB的数据做combine，显然对于一个key，在100MB的数据中可以找的到更多的values，也就是“压缩率”更高了。所以3MB的map的combiner效率就低了。
这就是为什么`COMBINE_OUTPUT_RECORDS`会这么大的原因。而且因为内存变小，map更加频繁地进行spill操作，导致文件更加多，执行归并排序所消耗的时间也越多。但是不管怎么样，
最终生成的临时打文件的大小是一样的。所以reducer的动作也是一样的。所以`io.sort.mb`影响的最多的其实就是map。

_所以尽可能将io.sort.mb调大，这样会提高运行的效率_。


[last post link]: http://blog.masr.in/hadoop_mapreduce_log
