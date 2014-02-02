---
layout: post
title:  "Hadoop的简单控制台log分析之mapred.compress.map.output"
date:   2013-10-15 16:00:00
category: geek
tags: hadoop map-reduce
---

<p class="excerpt">
<!--excerpt-->
紧接着上一篇文章的主题，这次在代码中添加mapred.compress.map.output。
<!--excerpt-->
</p>

`mapred.compress.map.output`的意思很简单，就是压缩map生成的中间结果，这样map最终生成的文件大小将会被压缩，从而减少了shuffle的网络带宽的消耗。默认是false。
该参数可以和`mapred.map.output.compression.codec`一起使用，该值的默认值是`org.apache.hadoop.io.compress.DefaultCodec`。
对应的代码是
{% highlight java %}
conf.setBoolean("mapred.compress.map.output", true);
{% endhighlight %}

首先我们来看以上这段代码的控制台结果，对应的解释嵌在结果里面。
{% highlight java %}
。。。。。。
。。。。。。
。。。。。。
INFO: Counters: 20
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:   File Output Format Counters
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Bytes Written=629401
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:   File Input Format Counters
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Bytes Read=52879822
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:   FileSystemCounters
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     FILE_BYTES_READ=663221779
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     FILE_BYTES_WRITTEN=28509494
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:   Map-Reduce Framework
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Map output materialized bytes=2174485
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Map input records=1252054
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Reduce shuffle bytes=0
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Spilled Records=784653
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Map output bytes=63190860
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     CPU time spent (ms)=0
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Total committed heap usage (bytes)=38070714368
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Combine input records=4020645
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     SPLIT_RAW_BYTES=2654
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Reduce input records=322311
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Reduce input groups=24731
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Combine output records=322311
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Physical memory (bytes) snapshot=0
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Reduce output records=24731
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Virtual memory (bytes) snapshot=0
Oct 15, 2013 5:18:24 PM org.apache.hadoop.mapred.Counters log
INFO:     Map output records=4020645
{% endhighlight %}

为了看得方便，我们把所有的counter都列出来。并且和不加任何参数的job作对比[here][last post link]。

####FileInputFormat task counters:

* Bytes Read=52879822(BYTES_READ)
数值不变。


####FileOputFormat task counters:

* Bytes Written=629401(BYTES_WRITTEN)
数值不变。


####FileSystemCounters:

* FILE_BYTES_READ=663221779
之前的数字是672008497，和之前差不多。我的理解是reducer在处理压缩数据的时候记录的是解压之后的大小。
* FILE_BYTES_WRITTEN=41921526
之前的数字是101705449，减少的原因是因为map写的文件是压缩过之后的文件，所以文件变小了。

####Map-Reduce Framework:

* Map input records=1252054(MAP_INPUT_RECORDS)
不变。
* Map output records=4020645(MAP_OUTPUT_RECORDS)
不变。
* Map output bytes=63190860(MAP_OUTPUT_BYTES)
不变。
* Combine input records=4020645(COMBINE_INPUT_RECORDS)
不变。
* Combine output records=322311(COMBINE_OUTPUT_RECORDS)
不变。
* Map output materialized bytes=2174485(MAP_OUTPUT_MATERIALIZED_BYTES)
原来的数字是7896423，体积减少为1/4，所以压缩率还是很可观的。
* Reduce input records=322311(REDUCE_INPUT_RECORDS)
不变。
* Reduce input groups=24731(REDUCE_INPUT_GROUPS)
不变。
* Reduce output records=24731(REDUCE_OUTPUT_RECORDS)
不变。
* Spilled Records=784653(SPILLED_RECORDS)
不变。

其实用map的压缩输出是一种balance，是以时间换取空间的做法。好处是中间结果变小了，网络带宽省下来了。
但是坏处是对于mapper和reducer的任务加重了，mapper需要将文件进行压缩，而reducer又需要对文件进行解压缩，等于是两次资源的消耗。



[last post link]:  http://blog.masr.in/hadoop_mapreduce_log