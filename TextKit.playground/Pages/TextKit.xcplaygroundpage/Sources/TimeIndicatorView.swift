import Foundation

import UIKit



public class TimeIndicatorView: UIView {
    
    //Label
    private var timeLabel:UILabel!
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public init(time:NSDate){
    
        super.init(frame:CGRect.init(x: 0, y: 0, width: 100, height: 100))
        backgroundColor = UIColor.yellow
        clipsToBounds = false
        
        timeLabel = UILabel()
        timeLabel.textAlignment = NSTextAlignment.center
        timeLabel.numberOfLines = 0
//        timeLabel.textColor = UIColor.blackColor()
        timeLabel.text = time.timeFormatBy(format: "dd\rMMMM\ryyyy")
        timeLabel.sizeToFit()
        
        addSubview(timeLabel)
    }

    public func updateSize() {
        //
        // size the label based on the font
        timeLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        timeLabel.frame = CGRect.init(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        //Make(0, 0, CGFloat.max, CGFloat.greatestFiniteMagnitude)
        timeLabel.sizeToFit()
        
        // set the frame to be large enough to accomodate circle that surrounds the text
        let radius = radiusToSurroundFrame(frame: timeLabel.frame)
        self.frame = CGRect.init(x: 0, y: 0, width: radius*2, height: radius*2)
        
        // center the label within this circle
        timeLabel.center = self.center
        
        // offset the center of this view to ... erm ... can I just draw you a picture?
        // You know the story - the designer provides a mock-up with some static data, leaving
        // you to work out the complex calculatins required to accomodate the variability of real-world
        // data. C'est la vie!
        let padding = CGFloat(5)
        self.center = CGPoint.init(x: self.center.x + timeLabel.frame.origin.x - padding, y: self.center.y - timeLabel.frame.origin.y + padding)
    }
    
    // calculates the radius of the circle that surrounds the label
    func radiusToSurroundFrame(frame:CGRect) -> CGFloat {
        //半径
        return max(frame.size.width, frame.size.height) * 0.5 + 20.0
    }
    
    func curvePathWithOrigin(origin:CGPoint)->UIBezierPath{
    
        //画弧形
        let path = UIBezierPath.init(arcCenter: origin,
                                     radius: radiusToSurroundFrame(frame: timeLabel.frame),
                                     startAngle: 0,
                                     endAngle: CGFloat(M_PI * 2),
                                     clockwise: true)
//        UIColor.blueColor().set()
//        path.fill()
//        UIColor.blueColor().set()
        return path
    }

    
    public override func draw(_ rect: CGRect) {
        
        //Returns the current graphics context.
        let ctx = UIGraphicsGetCurrentContext()
////        Sets anti-aliasing on or off for a graphics context.
////        Anti-aliasing is a graphics state parameter.
        ctx!.setShouldAntialias(true)
        let path = curvePathWithOrigin(origin: timeLabel.center)
        //填充色
        UIColor.blue.setFill()
        path.fill()
        
        //画笔色
//        path.lineWidth = 1.5
//        UIColor.redColor().set()
//        path.stroke()
    }
}

extension NSDate{

    func timeFormatBy(format:String) -> String {
        //
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = format
        return timeFormat.string(from: self as Date)
    }
}
