//
//  ViewController.swift
//  Lab
//
//  Created by Michael Bock on 2/24/16.
//  Copyright © 2016 Michael R. Bock. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var trayView: UIView!

    var trayOriginalCenter: CGPoint!
    var trayCenterWhenOpen: CGPoint!
    var trayCenterWhenClosed: CGPoint!

    var newlyCreatedFace: UIImageView!
    var newlyCreatedFaceOriginalCenter: CGPoint!

    var movingFace: UIImageView!
    var movingFaceOriginalCenter: CGPoint!
    var movingFaceOriginalScale: CGFloat!

    var scalingFace: UIImageView!

    var rotatingFace: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        trayCenterWhenOpen = trayView.center
        trayCenterWhenClosed = CGPoint(x: 160.0, y: 623.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTapGesture(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            if trayView.center == trayCenterWhenOpen {
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                    self.trayView.center = self.trayCenterWhenClosed
                    }, completion: { (finished) -> Void in
                        print("\(finished)")
                })
            } else if trayView.center == trayCenterWhenClosed {
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                    self.trayView.center = self.trayCenterWhenOpen
                    }, completion: { (finished) -> Void in
                        print("\(finished)")
                })
            }
        }
    }

    @IBAction func onPanGesture(sender: UIPanGestureRecognizer) {
        // Absolute (x,y) coordinates in parent view (parentView should be
        // the parent view of the tray)
        let point = sender.locationInView(view)

        if sender.state == UIGestureRecognizerState.Began {
            print("Gesture began at: \(point)")
            trayOriginalCenter = sender.view?.center
        } else if sender.state == UIGestureRecognizerState.Changed {
            print("Gesture changed at: \(point)")
            let translation = sender.translationInView(trayView.superview)
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
        } else if sender.state == UIGestureRecognizerState.Ended {
            print("Gesture ended at: \(point)")
            print("Ending center: \(trayView.center)")

            let velocity = sender.velocityInView(view).y

            if  velocity > 0.0 {  // Moving down.
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                        self.trayView.center = self.trayCenterWhenClosed
                    }, completion: { (finished) -> Void in
                        print("\(finished)")
                })
            } else if velocity < 0.0 {  // Moving up.
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                        self.trayView.center = self.trayCenterWhenOpen
                    }, completion: { (finished) -> Void in
                        print("\(finished)")
                })
            }
        }
    }

    @IBAction func onFaceGesture(sender: UIPanGestureRecognizer) {
        if sender.state == .Began {
            // Gesture recognizers know the view they are attached to.
            let imageView = sender.view as! UIImageView

            // Create a new image view that has the same image as the one currently panning.
            newlyCreatedFace = UIImageView(image: imageView.image)

            // Add the new face to the tray's parent view.
            view.addSubview(newlyCreatedFace)

            // Initialize the position of the new face.
            newlyCreatedFace.center = imageView.center

            // Since the original face is in the tray, but the new face is in the
            // main view, you have to offset the coordinates.
            newlyCreatedFace.center.y += trayView.frame.origin.y

            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
            newlyCreatedFace.userInteractionEnabled = true
            newlyCreatedFace.transform = CGAffineTransformMakeScale(1.25, 1.25)

            // Create a new pan gesture recognizer for the new imageview.
            let panGetsureRecognizer = UIPanGestureRecognizer(target: self, action: "onGrabFace:")
            newlyCreatedFace.addGestureRecognizer(panGetsureRecognizer)

            // Create a pinch gesture recognizer.
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "onPinchFace:")
            pinchGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(pinchGestureRecognizer)

            // Create a rotation gesture recognizer.
            let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "onRotateFace:")
            rotationGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(rotationGestureRecognizer)

        } else if sender.state == .Changed {
            let translation = sender.translationInView(view)
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
        } else if sender.state == .Ended {
            newlyCreatedFace.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }
    }

    func onGrabFace(sender: UIPanGestureRecognizer) {
        if sender.state == .Began {
            movingFace = sender.view as! UIImageView
            movingFaceOriginalCenter = movingFace.center
            movingFaceOriginalScale = movingFace.transform.a

            // Make the face bigger temporarily.
            movingFace.transform = CGAffineTransformMakeScale(movingFaceOriginalScale * 1.25, movingFaceOriginalScale * 1.25)
        } else if sender.state == .Changed {
            let translation = sender.translationInView(view)
            movingFace.center = CGPoint(x: movingFaceOriginalCenter.x + translation.x, y: movingFaceOriginalCenter.y + translation.y)
        } else if sender.state == .Ended {
            // Reset the face size.
            movingFace.transform = CGAffineTransformMakeScale(movingFaceOriginalScale, movingFaceOriginalScale)
        }
    }

    func onPinchFace(sender: UIPinchGestureRecognizer) {
        if sender.state == .Began {
            scalingFace = sender.view as! UIImageView
        } else if sender.state == .Changed{
            let scale = sender.scale
            scalingFace.transform = CGAffineTransformMakeScale(scale, scale)
        } else if sender.state == .Ended {
            // ?
        }
    }

    func onRotateFace(sender: UIRotationGestureRecognizer) {
        if sender.state == .Began {
            rotatingFace = sender.view as! UIImageView
        } else if sender.state == .Changed {
            let rotation = sender.rotation
            rotatingFace.transform = CGAffineTransformMakeRotation(rotation)
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

