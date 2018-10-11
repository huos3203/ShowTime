/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
@objc public protocol HorizontalScrollerDelegate {
  // ask the delegate how many views he wants to present inside the horizontal scroller
  func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> Int
  // ask the delegate to return the view that should appear at <index>
  func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index:Int) -> UIView
  // inform the delegate what the view at <index> has been clicked
  func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index:Int)
  // ask the delegate for the index of the initial view to display. this method is optional
  // and defaults to 0 if it's not implemented by the delegate
    @objc optional func initialViewIndex(scroller: HorizontalScroller) -> Int
}

public class HorizontalScroller: UIView {
  public weak var delegate: HorizontalScrollerDelegate?
  // 1
  private let VIEW_PADDING = 10
  private let VIEW_DIMENSIONS = 100
  private let VIEWS_OFFSET = 100

  // 2
  private var scroller : UIScrollView!
  // 3
  var viewArray = [UIView]()

  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeScrollView()
  }

  public required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    initializeScrollView()
  }

  public func initializeScrollView() {
    //1
    scroller = UIScrollView()
    scroller.delegate = self
    addSubview(scroller)

    //2
    scroller.translatesAutoresizingMaskIntoConstraints = false
    //3
    self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
    self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
    self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
    self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))

    //4
    let tapRecognizer = UITapGestureRecognizer(target: self, action:Selector(("scrollerTapped:")))
    scroller.addGestureRecognizer(tapRecognizer)
  }

  public func viewAtIndex(index :Int) -> UIView {
    return viewArray[index]
  }

  public func scrollerTapped(gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: gesture.view)
    if let delegate = delegate {
        for index in 0..<delegate.numberOfViewsForHorizontalScroller(scroller: self) {
            let view = scroller.subviews[index]
            if view.frame.contains(location) {
                delegate.horizontalScrollerClickedViewAtIndex(scroller: self, index: index)
          scroller.setContentOffset(CGPoint(x: view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, y: 0), animated:true)
          break
        }
      }
    }
  }

  public override func didMoveToSuperview() {
    reload()
  }

  public func reload() {
    // 1 - Check if there is a delegate, if not there is nothing to load.
    if let delegate = delegate {
      //2 - Will keep adding new album views on reload, need to reset.
      viewArray = []
        let views: Array = scroller.subviews

			// 3 - remove all subviews
			for view in views {
                view.removeFromSuperview()
			}

      // 4 - xValue is the starting point of the views inside the scroller
      var xValue = VIEWS_OFFSET
        for index in 0..<delegate.numberOfViewsForHorizontalScroller(scroller: self) {
        // 5 - add a view at the right position
        xValue += VIEW_PADDING
            let view = delegate.horizontalScrollerViewAtIndex(scroller: self, index: index)
            view.frame = CGRect.init(x: CGFloat(xValue), y: CGFloat(VIEW_PADDING), width: CGFloat(VIEW_DIMENSIONS), height: CGFloat(VIEW_DIMENSIONS))
        scroller.addSubview(view)
        xValue += VIEW_DIMENSIONS + VIEW_PADDING
        // 6 - Store the view so we can reference it later
        viewArray.append(view)
      }
      // 7
      scroller.contentSize = CGSize.init(width: CGFloat(xValue + VIEWS_OFFSET), height: frame.size.height)

      // 8 - If an initial view is defined, center the scroller on it
        if let initialView = delegate.initialViewIndex?(scroller: self) {
        scroller.setContentOffset(CGPoint(x: CGFloat(initialView)*CGFloat((VIEW_DIMENSIONS + (2 * VIEW_PADDING))), y: 0), animated: true)
      }
    }
  }

  public func centerCurrentView() {
    var xFinal = Int(scroller.contentOffset.x) + (VIEWS_OFFSET/2) + VIEW_PADDING
    let viewIndex = xFinal / (VIEW_DIMENSIONS + (2*VIEW_PADDING))
    xFinal = viewIndex * (VIEW_DIMENSIONS + (2*VIEW_PADDING))
		scroller.setContentOffset(CGPoint(x: xFinal, y: 0), animated: true)
    if let delegate = delegate {
        delegate.horizontalScrollerClickedViewAtIndex(scroller: self, index: Int(viewIndex))
    }  
  }
}

extension HorizontalScroller: UIScrollViewDelegate {
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      centerCurrentView()
    }
  }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    centerCurrentView()
  }
}
