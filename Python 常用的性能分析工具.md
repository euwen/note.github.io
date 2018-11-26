一. 基本的查询运行时间工具 — time
性能分析最基本的就是查看某段代码的运行时间，这个最常规简单的方式就是通过 Python 的 time 模块进行计算，代码示例如下:

    def add(a, b)
      retutn a + b

    import time

    # 代码运行开始前的时间
    start = time.time()

    result = add(1, 2)
    # 代码运行结束后的时间
    end = time.time()
    # 计算时间消耗
    escape = end - start
    # 打印查看
    print(escape)


二. 通过 timeit 模块计算代码执行时间
Python 提供了 timeit 模块来测量代码的执行速度，可以用该模块来对各种简单的语句进行计时

代码示例:

    python3.6 -m timeit -n 5 -r 5 -s "import module_name" "module_name.func(*args, **kwargs)"

简要对上面的语句作下说明:

-m: 指定要作为脚本运行的内置模块名称，这里就是 timeit 模块\\
-n: 表示 timeit 要对执行的代码循环执行 n 次\\
-r: 表示 timeit 会重复 r 次执行。 -n 与 -r 的表示的意思就是，timeit 模块首先会对要执行的代码循环执行 n 次，取 n 次的平均值作为一个结果，然后重复 r 次，这样就得到了 r 个结果，然后选出最好的结果进行返回\\
-s: 表示导入要执行的代码所属的 module, 后面就是通过 module_name.func_name() 表示要测试执行的代码了\\
使用 timeit 模块有几点注意:

timeit 模块暂时禁用了垃圾收集器，当你的操作会调用到垃圾收集器时可能会影响到实际操作的速度
在 ipython 中也可以使用 %timeit 模块，实例代码如下:

    In [1]: from module_name import func_name

    In [2]: %timeit func_name(*args, **kwargs)


三. Unix 系统命令 time 计时
Unix 提供了系统命令 time， 可以用它来记录程序耗费的各方面时间

    /usr/bin/time -lp demo.py

-p 命令会显示三个结果:

real: 记录整体的耗时
user: 记录 CPU 花在任务上的时间，但不包括内核函数耗费的时间
sys: 记录了内核函数耗费的时间
加上 -l 命令之后会显示更多信息，如下： 
 

关于 time 命令就记这些吧，基本够用，详细用法可以参与这篇文档: time 命令

四. cProfile 模块
cProfile 是标准库内建的分析工具，可以用来测量每一个函数的执行时间。其基本的使用命令如下:

    python -m cProfile -s cumulative cp02/demo01.py

-m 表示执行 cProfile 模块， -s cumulative 表示对每个函数累计花费时间进行排序，可以让我们很直观的看到哪一部分的代码执行的最慢。 
其结果如下:

更好用的方式是生成一个统计文件，然后通过 pstats 模块进行分析，命令如下:

    python -m cProfile -o profile.stats cp02/demo01.py

这样将统计结果存储到 profile.stats 文件之后就可以通过 pstats 模块来查看了，代码如下:

    import pstats
    #
    # p = pstats.Stats('profile.stats')
    # p.sort_stats("cumulative")
    # 输出累计时间报告
    p.print_stats()
    # 输出调用者的信息
    p.print_callers()
    # 输出哪个函数调用了哪个函数
    p.print_callees()

print_stats() 函数的输出其各项的含义如下：

ncalls: 函数执行次数
tottime: 累计耗时
percall: 每次耗时
cumtime: 包括子函数的执行时间
percall 每次的执行时间
filename:lineno(function): 文件名+代码行数+方法名
通过 cProfile 可以快速的定位出现性能瓶颈的函数，然后在针对函数进行进一步的分析。下面是逐行代码分析的 line_profiler 工具

五. line_profiler – 逐行代码分析工具
line_profiler 可以对函数进行逐行分析，是调查 Python 的 CPU 密集型问题最强大的工具。通常的使用步骤是先用 cProfile 进行函数分析， 
然后在对有性能瓶颈的函数进行逐行分析。

1.安装 line_profiler
    pip install line_profiler

2. 使用 line_profiler
首先在要分析的函数上添加装饰器 @profile
然后使用 kernprof 命令执行对应的 Python 代码，如下:
    kernprof -l cp02/demo01.py

-l 参数那个了表示逐行分析，另外还可以有 -v 参数用来显示输出，不加的话会生成一个 .lprof 的输出文件。得到文件后可以用下面命令查看:

    python -m line_profiler demo01.py.lprof

其各项含义为:

Line: 代码行数
Hits: 执行次数
Time: 占用的总时间
Per Hit: 每次执行的时间
Time: 时间占比
Line Contents: 代码内容
注意，在下面提到的 memory_profiler 中也会有一个 @profile 的装饰器，会和 line_profiler 的冲突，使用的时候不要弄混了。

六. memory_profiler – 诊断内存的用量
memory_profiler 模块能够逐行测量内存的占用情况

1. 安装
    pip install psutil # 需要先安装 psutil 模块
    pip install memory_profiler

2. 使用
命令如下:

        python -m memory_profiler cp02/demo01.py

得到结果各项含义为

Mem Usage: 内存占用情况
Increment: 执行该行代码后新增的内存
另外 memory_profiler 提供了一个 mprof 进行可视化的内存展示，使用该命令需要安装 matplotlib

    pip install matplotlib

然后执行如下命令:

    mprof run cp02/demo01.py  # 生成统计文件
    mprof plot mprofile_20170904220625.dat  # 展示统计文件

--------------------- 
原文：https://blog.csdn.net/Ahri_J/article/details/77860246 
