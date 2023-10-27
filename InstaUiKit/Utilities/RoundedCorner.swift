//
//  RoundedCorner.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//
import UIKit

class RoundedButton: UIButton {
    // Custom corner radius value
    
    var cornerRadius: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set corner radius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
}



class RoundedButtonWithBorder: UIButton {
    // Custom corner radius value
    var cornerRadius: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    // Custom border width value
    var borderWidth: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    // Custom border color value
    var borderColor: UIColor = .gray {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set corner radius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        
        // Set border
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }
}

class RoundedViewWithBorder: UIView {
    // Custom corner radius value
    var cornerRadius: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    // Custom border width value
    var borderWidth: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    // Custom border color value
    var borderColor: UIColor = .gray {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set corner radius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        
        // Set border
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }
}

class CircleImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set the corner radius to half of the view's width to make it a circle
        layer.cornerRadius = bounds.width / 2
        layer.masksToBounds = true
    }
}

class ViewWithBorder: UIView {
    // Custom border width value
    var borderWidth: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    // Custom border color value
    var borderColor: UIColor = .black {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set border
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }
}
