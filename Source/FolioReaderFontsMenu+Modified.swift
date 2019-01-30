//
//  FolioReaderFontsMenuModified.swift
//  AEXML
//
//  Created by Treinetic-Macbook on 1/30/19.
//


import UIKit

class FolioReaderFontsMenuModified: UIViewController, SMSegmentViewDelegate, UIGestureRecognizerDelegate {
    var menuView: UIView!
    
    fileprivate var readerConfig: FolioReaderConfig
    fileprivate var folioReader: FolioReader
    
    let normalColor = UIColor(white: 0.5, alpha: 0.7)
    var selectedColor = UIColor(white: 0.0, alpha: 0.7)
    let sun = UIImage(readerImageNamed: "icon-sun")
    let moon = UIImage(readerImageNamed: "icon-moon")
    let fontSmall = UIImage(readerImageNamed: "icon-font-small")
    let fontBig = UIImage(readerImageNamed: "icon-font-big")
    
    init(folioReader: FolioReader, readerConfig: FolioReaderConfig) {
        self.readerConfig = readerConfig
        self.folioReader = folioReader
        selectedColor = self.readerConfig.tintColor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FolioReaderFontsMenu.tapGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        // Menu view
        var visibleHeight: CGFloat = self.readerConfig.canChangeScrollDirection ? 222 : 170
        visibleHeight = self.readerConfig.isFontEnabled ? visibleHeight : visibleHeight - 55
        menuView = UIView(frame: CGRect(x: 0, y: view.frame.height-visibleHeight, width: view.frame.width, height: view.frame.height))
        menuView.backgroundColor = self.folioReader.isNight(self.readerConfig.nightModeMenuBackground, UIColor.white)
        menuView.autoresizingMask = .flexibleWidth
        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowOffset = CGSize(width: 0, height: 0)
        menuView.layer.shadowOpacity = 0.3
        menuView.layer.shadowRadius = 6
        menuView.layer.shadowPath = UIBezierPath(rect: menuView.bounds).cgPath
        menuView.layer.rasterizationScale = UIScreen.main.scale
        menuView.layer.shouldRasterize = true
        view.addSubview(menuView)
        
        var top = CGFloat(0)
        let width = menuView.frame.width
        let dayNNight = getDayNight(width: width)
        menuView.addSubview(dayNNight)
        top += dayNNight.bounds.height
        
        let line1 = getLineSeperator(width: width, top: top)
        menuView.addSubview(line1)
        top += line1.bounds.height
        
        if self.readerConfig.isFontEnabled {
            let fontSelect = getFontSelector(width: menuView.frame.width, top : top)
            menuView.addSubview(fontSelect)
            top += fontSelect.bounds.height
            
            let line2 = getLineSeperator(width: width, top: top)
            menuView.addSubview(line2)
            top += line2.bounds.height
        }
        
        let slider = getFontSlider(width: menuView.frame.width, top : top)
        menuView.addSubview(slider)
        top += slider.bounds.height
        
        let line3 = getLineSeperator(width: width, top: top)
        menuView.addSubview(line3)
        top += line3.bounds.height
        
        if self.readerConfig.canChangeScrollDirection {
            let scrolDir = getScrollDirection(width: menuView.frame.width, top : top)
            menuView.addSubview(scrolDir)
        }
        
    }
    
    // MARK: - SMSegmentView delegate
    
    func segmentView(_ segmentView: SMSegmentView, didSelectSegmentAtIndex index: Int) {
        guard (self.folioReader.readerCenter?.currentPage) != nil else { return }
        
        if segmentView.tag == 1 {
            
            self.folioReader.nightMode = Bool(index == 1)
            
            UIView.animate(withDuration: 0.6, animations: {
                self.menuView.backgroundColor = (self.folioReader.nightMode ? self.readerConfig.nightModeBackground : UIColor.white)
            })
            
        } else if segmentView.tag == 2 {
            
            self.folioReader.currentFont = FolioReaderFont(rawValue: index)!
            
        }  else if segmentView.tag == 3 {
            
            guard self.folioReader.currentScrollDirection != index else {
                return
            }
            
            self.folioReader.currentScrollDirection = index
        }
    }
    
    // MARK: - Font slider changed
    
    @objc func sliderValueChanged(_ sender: HADiscreteSlider) {
        guard
            (self.folioReader.readerCenter?.currentPage != nil),
            let fontSize = FolioReaderFontSize(rawValue: Int(sender.value)) else {
                return
        }
        
        self.folioReader.currentFontSize = fontSize
    }
    
    // MARK: - Gestures
    
    @objc func tapGesture() {
        dismiss()
        
        if (self.readerConfig.shouldHideNavigationOnTap == false) {
            self.folioReader.readerCenter?.showBars()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer && touch.view == view {
            return true
        }
        return false
    }
    
    // MARK: - Status Bar
    
    override var prefersStatusBarHidden : Bool {
        return (self.readerConfig.shouldHideNavigationOnTap == true)
    }
}

extension FolioReaderFontsMenuModified {
    
    
    private func getStack() -> UIStackView {
        var height = self.readerConfig.canChangeScrollDirection ? 222 : 170
        height = self.readerConfig.isFontEnabled ? height : height - 55
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        return stack
    }
    
    private func getFontSelector(width : CGFloat, top : CGFloat) -> UIView {
        let fontName = SMSegmentView(frame: CGRect(x: 0, y: top, width: width, height: 55),
                                    separatorColour: UIColor.clear,
                                     separatorWidth: 0,
                                     segmentProperties:  [
                                        keySegmentOnSelectionColour: UIColor.clear,
                                        keySegmentOffSelectionColour: UIColor.clear,
                                        keySegmentOnSelectionTextColour: selectedColor,
                                        keySegmentOffSelectionTextColour: normalColor,
                                        keyContentVerticalMargin: 17 as AnyObject])
        fontName.delegate = self
        fontName.tag = 2
        fontName.addSegmentWithTitle("Andada", onSelectionImage: nil, offSelectionImage: nil)
        fontName.addSegmentWithTitle("Lato", onSelectionImage: nil, offSelectionImage: nil)
        fontName.addSegmentWithTitle("Lora", onSelectionImage: nil, offSelectionImage: nil)
        fontName.addSegmentWithTitle("Raleway", onSelectionImage: nil, offSelectionImage: nil)
        fontName.selectSegmentAtIndex(self.folioReader.currentFont.rawValue)
        
        return fontName
    }
    
    private func getDayNight(width : CGFloat) -> UIView {
        let sunNormal = sun?.imageTintColor(normalColor)?.withRenderingMode(.alwaysOriginal)
        let moonNormal = moon?.imageTintColor(normalColor)?.withRenderingMode(.alwaysOriginal)
        let fontSmallNormal = fontSmall?.imageTintColor(normalColor)?.withRenderingMode(.alwaysOriginal)
        let fontBigNormal = fontBig?.imageTintColor(normalColor)?.withRenderingMode(.alwaysOriginal)
        
        let sunSelected = sun?.imageTintColor(selectedColor)?.withRenderingMode(.alwaysOriginal)
        let moonSelected = moon?.imageTintColor(selectedColor)?.withRenderingMode(.alwaysOriginal)
        
        // Day night mode
        let dayNight = SMSegmentView(frame: CGRect(x: 0, y: 0, width: width, height: 55),
                                     separatorColour: self.readerConfig.nightModeSeparatorColor,
                                     separatorWidth: 1,
                                     segmentProperties:  [
                                        keySegmentTitleFont: UIFont(name: "Avenir-Light", size: 17)!,
                                        keySegmentOnSelectionColour: UIColor.clear,
                                        keySegmentOffSelectionColour: UIColor.clear,
                                        keySegmentOnSelectionTextColour: selectedColor,
                                        keySegmentOffSelectionTextColour: normalColor,
                                        keyContentVerticalMargin: 17 as AnyObject
            ])
        dayNight.delegate = self
        dayNight.tag = 1
        dayNight.addSegmentWithTitle(self.readerConfig.localizedFontMenuDay, onSelectionImage: sunSelected, offSelectionImage: sunNormal)
        dayNight.addSegmentWithTitle(self.readerConfig.localizedFontMenuNight, onSelectionImage: moonSelected, offSelectionImage: moonNormal)
        dayNight.selectSegmentAtIndex(self.folioReader.nightMode ? 1 : 0)
        return dayNight
    }
    
    private func getFontSlider(width : CGFloat, top : CGFloat) -> UIView {
        
        let fontSmallNormal = fontSmall?.imageTintColor(normalColor)?.withRenderingMode(.alwaysOriginal)
        let fontBigNormal = fontBig?.imageTintColor(normalColor)?.withRenderingMode(.alwaysOriginal)
        
        
        let container = UIView()
        container.frame = CGRect(x: 0, y: top, width: width, height: 55)
        
        let slider = HADiscreteSlider(frame: CGRect(x: 50, y: 0, width: width - 100, height: 55))
        slider.tickStyle = ComponentStyle.rounded
        slider.tickCount = 5
        slider.tickSize = CGSize(width: 8, height: 8)
        
        slider.thumbStyle = ComponentStyle.rounded
        slider.thumbSize = CGSize(width: 28, height: 28)
        slider.thumbShadowOffset = CGSize(width: 0, height: 2)
        slider.thumbShadowRadius = 3
        slider.thumbColor = selectedColor
        
        slider.backgroundColor = UIColor.clear
        slider.tintColor = self.readerConfig.nightModeSeparatorColor
        slider.minimumValue = 0
        slider.value = CGFloat(self.folioReader.currentFontSize.rawValue)
        slider.addTarget(self, action: #selector(FolioReaderFontsMenu.sliderValueChanged(_:)), for: UIControlEvents.valueChanged)
        
        // Force remove fill color
        slider.layer.sublayers?.forEach({ layer in
            layer.backgroundColor = UIColor.clear.cgColor
        })
        
        // Font icons
        let fontSmallView = UIImageView(frame: CGRect(x: 20, y: 10 , width: 30, height: 30))
        fontSmallView.image = fontSmallNormal
        fontSmallView.contentMode = UIViewContentMode.center
        
        let fontBigView = UIImageView(frame: CGRect(x: slider.frame.width + 50, y: 10 , width: 30, height: 30))
        fontBigView.image = fontBigNormal
        fontBigView.contentMode = UIViewContentMode.center
        
        container.addSubview(slider)
        container.addSubview(fontSmallView)
        container.addSubview(fontBigView)
        return container
    }
    
    private func getScrollDirection(width : CGFloat, top : CGFloat) -> UIView {
        let vertical = UIImage(readerImageNamed: "icon-menu-vertical")
        let horizontal = UIImage(readerImageNamed: "icon-menu-horizontal")
        let verticalNormal = vertical?.imageTintColor(normalColor)?.withRenderingMode(.alwaysOriginal)
        let horizontalNormal = horizontal?.imageTintColor(normalColor)?.withRenderingMode(.alwaysOriginal)
        let verticalSelected = vertical?.imageTintColor(selectedColor)?.withRenderingMode(.alwaysOriginal)
        let horizontalSelected = horizontal?.imageTintColor(selectedColor)?.withRenderingMode(.alwaysOriginal)
        
        // Layout direction
        let layoutDirection = SMSegmentView(frame: CGRect(x: 0, y: top, width: width, height: 55),
                                            separatorColour: self.readerConfig.nightModeSeparatorColor,
                                            separatorWidth: 1,
                                            segmentProperties:  [
                                                keySegmentTitleFont: UIFont(name: "Avenir-Light", size: 17)!,
                                                keySegmentOnSelectionColour: UIColor.clear,
                                                keySegmentOffSelectionColour: UIColor.clear,
                                                keySegmentOnSelectionTextColour: selectedColor,
                                                keySegmentOffSelectionTextColour: normalColor,
                                                keyContentVerticalMargin: 17 as AnyObject
            ])
        layoutDirection.delegate = self
        layoutDirection.tag = 3
        layoutDirection.frame.size.height = 55
        layoutDirection.addSegmentWithTitle(self.readerConfig.localizedLayoutVertical, onSelectionImage: verticalSelected, offSelectionImage: verticalNormal)
        layoutDirection.addSegmentWithTitle(self.readerConfig.localizedLayoutHorizontal, onSelectionImage: horizontalSelected, offSelectionImage: horizontalNormal)
        
        var scrollDirection = FolioReaderScrollDirection(rawValue: self.folioReader.currentScrollDirection)
        
        if scrollDirection == .defaultVertical && self.readerConfig.scrollDirection != .defaultVertical {
            scrollDirection = self.readerConfig.scrollDirection
        }
        
        switch scrollDirection ?? .vertical {
        case .vertical, .defaultVertical:
            layoutDirection.selectSegmentAtIndex(FolioReaderScrollDirection.vertical.rawValue)
        case .horizontal, .horizontalWithVerticalContent:
            layoutDirection.selectSegmentAtIndex(FolioReaderScrollDirection.horizontal.rawValue)
        }
        return layoutDirection
    }
    
    private func getLineSeperator(width : CGFloat ,top : CGFloat) -> UIView {
        let line = UIView()
        line.frame.size.height = 1
        line.frame.size.width = width
        line.frame.origin.y = top
        line.backgroundColor = self.readerConfig.nightModeSeparatorColor
        return line
    }
    
}
