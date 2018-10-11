import NameShape
class EquilateralTriangle:NamedShape
{
    var sideLength:Double = 0.0
    init(sideLength:Double,name:String)
    {
        self.sideLength = sideLength
        super.init(name:name)
        numberOfSides = 3
    }
}
