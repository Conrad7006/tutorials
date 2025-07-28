# This file explains how to use threads
## Basics
versioninfo()       # Gives hardware and environment info
Threads.nthreads()  # Shows how many cores are currently being used

## To change threads
#=
click on the settings icon
search for "threads"
click "edit in json settings"
change number to integer from 1 to max threads 
remember to save
=#

## Example
Threads.threadid()      # Shows the thread of current excecution

### Single thread
for i in 1:Threads.nthreads()
    println("i:", i, "\t Thread ID:", Threads.threadid())
end

#=
Shows how each iteration is excecuted by the same thread
The first thread is the master thread by default
=#

### Multiple threads
Threads.@threads for i in 1:Threads.nthreads()      # Allows for multiple threads
    println("i:", i, "\t Thread ID:", Threads.threadid())
end

#=
All cores used, but index numbers are not in oder
Cores are teamed up with random index numbers
Output will differ with each run
=#

## Data race example
n = 2_000_000
myvector = collect(1:n)

sum(myvector)

### single threaded function
function multi_sum1(myvector)
    temp = 0
    for i in eachindex(myvector)
        temp += myvector[i]
    end
    return temp 
end

multi_sum1(myvector)        # same answer

### Multi threaded function
function multi_sum2(myvector)
    temp = 0
    Threads.@threads for i in eachindex(myvector)
        temp += myvector[i]
    end
    return temp 
end

multi_sum2(myvector)        # Different answer --> changes every time

#=
Each parralel version has access to temp --> overwrite the value of temp
=#

### Solution
function multi_sum3(myvector)
    temp = zeros(Int, Threads.nthreads())       # Preallocate for each thread

    Threads.@threads for i in eachindex(myvector)
        temp[Threads.threadid()] += myvector[i]     # Each thread sums its individual part
    end
    for i in eachindex(temp)
        println(i, "/t = ", temp[i])
    end
    return sum(temp)
end

multi_sum3(myvector)        # Even though individual totals change, the overall is correct

## Compare times

@time multi_sum3(myvector)
@time sum(myvector)     

#=
 Built-in seems to be faster (even though it is single-thread)
 Multi-thread is only faster when we increase the vector to 2 billion
 Multi-thread is only useful when we are using very large/long operations
=#
