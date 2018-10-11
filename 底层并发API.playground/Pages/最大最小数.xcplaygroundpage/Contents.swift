//从一个数组中找到其中的最大值，和最小值？
//时间复杂度O(2n)
let sourceArray = [4,1,3,9,0,2,6,7,5,8]
var minNum:Int = 0 ,maxNum:Int = 0
for i in 0 ..< sourceArray.count
{
    let currentNum = sourceArray[i]
    if minNum > currentNum
    {
        minNum  = currentNum
    }
    if maxNum < currentNum
    {
        maxNum = currentNum
    }
}
minNum
maxNum

