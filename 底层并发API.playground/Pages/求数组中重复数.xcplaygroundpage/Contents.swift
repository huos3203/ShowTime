//假设有100个数，用函数返回重复数的数组？
//
var array = [1,4,6,5,0,2,1,4,6,3,4]
var sameArray:[Int] = []
for i in 0 ..< array.count {
    let currentNum = array[i]
    for j in 0 ..< array.count {
        if currentNum == array[j] && i != j {
            sameArray.append(j)
        }
    }
}
sameArray
