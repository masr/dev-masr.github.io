---
layout: post
title:  "Hadoop的简单控制台log分析之io.sort.factor"
date:   2013-10-15 13:00:00
category: geek
tags: hadoop map-reduce
---

<p class="excerpt">
<!--excerpt-->
紧接着上一篇文章的主题，这次在代码中修改一些conf的参数，再观察一下hadoop的行为。本文介绍io.sort.factor。
<!--excerpt-->
</p>

`io.sort.factor`的意思是在mapper或者reducer端，进行一次归并排序最多可以同时合并的文件的个数。默认值是10.也就是可以最多同时合并10个文件成一个大文件。
这里我们将这个值改成2。并且内存仍然设置成3MB。观察一下hadoop的行为。
对应的代码是
{% highlight java %}
conf.set("io.sort.mb", "3");
conf.set("io.sort.factor", "2");
{% endhighlight %}

首先我们来看以上这段代码的控制台结果，对应的解释嵌在结果里面。
{% highlight java %}
。。。。。。
。。。。。。
。。。。。。
//看第12个map
INFO: Starting task: attempt_local926435011_0001_m_000012_0
Oct 15, 2013 2:07:05 PM org.apache.hadoop.mapred.Task initialize
INFO:  Using ResourceCalculatorPlugin : org.apache.hadoop.util.LinuxResourceCalculatorPlugin@5e2c17f7
Oct 15, 2013 2:07:05 PM org.apache.hadoop.mapred.MapTask runNewMapper
INFO: Processing split: file:/home/coolmore/workspace/eclipse/HadoopStudy/data/in/hadoop_0.18.1.xml:0+1883089
Oct 15, 2013 2:07:05 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer <init>
INFO: io.sort.mb = 3
Oct 15, 2013 2:07:05 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer <init>
INFO: data buffer = 2390758/2988448
Oct 15, 2013 2:07:05 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer <init>
INFO: record buffer = 7864/9830
Oct 15, 2013 2:07:05 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer collect
INFO: Spilling map output: record full = true
Oct 15, 2013 2:07:05 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer startSpill
INFO: bufstart = 0; bufend = 124118; bufvoid = 2988448
Oct 15, 2013 2:07:05 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer startSpill
INFO: kvstart = 0; kvend = 7864; length = 9830
Oct 15, 2013 2:07:05 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer sortAndSpill
INFO: Finished spill 0
Oct 15, 2013 2:07:05 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer collect
INFO: Spilling map output: record full = true
Oct 15, 2013 2:07:05 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer startSpill
INFO: bufstart = 124118; bufend = 258921; bufvoid = 2988448
Oct 15, 2013 2:07:05 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer startSpill
INFO: kvstart = 7864; kvend = 5897; length = 9830
Oct 15, 2013 2:07:05 PM org.apache.hadoop.mapred.MapTask$MapOutputBuffer sortAndSpill
INFO: Finished spill 1
。。。。。。
。。。。。。
。。。。。。
INFO: Finished spill 18
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
//以上的部分和是受到了io.sort.mb的影响，而下面merge文件的操作是受到了io.sort.factor的影响。
INFO: Merging 19 sorted segments
//因为io.sort.factor被设置成了2，所以最多能同时合并2个文件，所以只能两个两个合并。
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 19
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 18
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 17
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 16
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 15
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 14
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 13
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 12
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 11
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 10
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 9
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 8
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 7
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 6
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 5
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 4
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 3
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
//最后只剩下了两个文件，继续做merge，真是蛋疼啊！
INFO: Down to the last merge-pass, with 2 segments left of total size: 500051 bytes
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Task done
INFO: Task:attempt_local926435011_0001_m_000012_0 is done. And is in the process of commiting
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.LocalJobRunner$Job statusUpdate
INFO:
Oct 15, 2013 2:07:06 PM org.apache.hadoop.mapred.Task sendDone
INFO: Task 'attempt_local926435011_0001_m_000012_0' done.
。。。。。。
。。。。。。
。。。。。。
INFO:  map 100% reduce 0%
//同样的，reducer也要两个两个合并，总共有19个map，所以有19个大文件。
INFO: Merging 19 sorted segments
Oct 15, 2013 2:07:14 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 19
Oct 15, 2013 2:07:14 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 18
Oct 15, 2013 2:07:14 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 17
Oct 15, 2013 2:07:14 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 16
Oct 15, 2013 2:07:14 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 15
Oct 15, 2013 2:07:14 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 14
Oct 15, 2013 2:07:15 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 13
Oct 15, 2013 2:07:15 PM org.apache.hadoop.mapred.JobClient monitorAndPrintJob
INFO:  map 100% reduce 0%
Oct 15, 2013 2:07:15 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 12
Oct 15, 2013 2:07:15 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 11
Oct 15, 2013 2:07:15 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 10
Oct 15, 2013 2:07:15 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 9
Oct 15, 2013 2:07:15 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 8
Oct 15, 2013 2:07:15 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 7
Oct 15, 2013 2:07:15 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 6
Oct 15, 2013 2:07:15 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 5
Oct 15, 2013 2:07:16 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 4
Oct 15, 2013 2:07:16 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Merging 2 intermediate segments out of a total of 3
Oct 15, 2013 2:07:16 PM org.apache.hadoop.mapred.Merger$MergeQueue merge
INFO: Down to the last merge-pass, with 2 segments left of total size: 7896313 bytes
Oct 15, 2013 2:07:16 PM org.apache.hadoop.mapred.LocalJobRunner$Job statusUpdate
INFO:
Oct 15, 2013 2:07:17 PM org.apache.hadoop.mapred.Task done
INFO: Task:attempt_local926435011_0001_r_000000_0 is done. And is in the process of commiting
Oct 15, 2013 2:07:17 PM org.apache.hadoop.mapred.LocalJobRunner$Job statusUpdate
INFO:
Oct 15, 2013 2:07:17 PM org.apache.hadoop.mapred.Task commit
INFO: Task attempt_local926435011_0001_r_000000_0 is allowed to commit now
Oct 15, 2013 2:07:17 PM org.apache.hadoop.mapreduce.lib.output.FileOutputCommitter commitTask
INFO: Saved output of task 'attempt_local926435011_0001_r_000000_0' to /home/coolmore/workspace/eclipse/HadoopStudy/data/out
Oct 15, 2013 2:07:17 PM org.apache.hadoop.mapred.LocalJobRunner$Job statusUpdate
INFO: reduce > reduce
Oct 15, 2013 2:07:17 PM org.apache.hadoop.mapred.Task sendDone
INFO: Task 'attempt_local926435011_0001_r_000000_0' done.
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.JobClient monitorAndPrintJob
INFO:  map 100% reduce 100%
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.JobClient monitorAndPrintJob
INFO: Job complete: job_local926435011_0001
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO: Counters: 20
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:   File Output Format Counters
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Bytes Written=629401
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:   File Input Format Counters
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Bytes Read=52879822
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:   FileSystemCounters
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     FILE_BYTES_READ=1581142552
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     FILE_BYTES_WRITTEN=1010838824
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:   Map-Reduce Framework
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Map output materialized bytes=7896423
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Map input records=1252054
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Reduce shuffle bytes=0
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Spilled Records=5046767
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Map output bytes=63190860
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     CPU time spent (ms)=0
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Total committed heap usage (bytes)=2333868032
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Combine input records=4715126
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     SPLIT_RAW_BYTES=2654
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Reduce input records=322311
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Reduce input groups=24731
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Combine output records=1016792
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Physical memory (bytes) snapshot=0
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Reduce output records=24731
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Virtual memory (bytes) snapshot=0
Oct 15, 2013 2:07:18 PM org.apache.hadoop.mapred.Counters log
INFO:     Map output records=4020645

{% endhighlight %}

为了看得方便，我们把所有的counter都列出来。我们将和[here][last post link]中的数据作对比。

####FileInputFormat task counters:

* Bytes Read=52879822(BYTES_READ)
数值没变。


####FileOputFormat task counters:

* Bytes Written=629401(BYTES_WRITTEN)
数值没变。


####FileSystemCounters:

* FILE_BYTES_READ=1581142552
之前的数字是980198949。
* FILE_BYTES_WRITTEN=409895781
之前的数据是101705449。
这两个数字变大的原因是map和reducer不断地在进行文件的合并，数据不断地读取落地读取落地……

####Map-Reduce Framework:

* Map input records=1252054(MAP_INPUT_RECORDS)
数值不变。
* Map output records=4020645(MAP_OUTPUT_RECORDS)
数值不变。
* Map output bytes=63190860(MAP_OUTPUT_BYTES)
数值不变。
* Combine input records=4715126(COMBINE_INPUT_RECORDS)
数值不变。这里combiner好像只是受到了`io.sort.mb`的影响。
* Combine output records=1016792(COMBINE_OUTPUT_RECORDS)
数值不变。
* Map output materialized bytes=7896423(MAP_OUTPUT_MATERIALIZED_BYTES)
数值不变。
* Reduce input records=322311(REDUCE_INPUT_RECORDS)
数值不变。
* Reduce input groups=24731(REDUCE_INPUT_GROUPS)
数值不变。
* Reduce output records=24731(REDUCE_OUTPUT_RECORDS)
数值不变。
* Spilled Records=5046767(SPILLED_RECORDS)
原来的数字是1961335，这里多出来的部分就是文件多次归并的开销。

_所以尽可能加大io.sort.factor，这样可以提高io的效率_。


[last post link]:  http://blog.masr.in/hadoop_mapreduce_log_io_sort_mb
