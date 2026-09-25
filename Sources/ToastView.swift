import UIKit

open class ToastView: UIView {

  // MARK: Properties

  open var text: String? {
    get { return self.textLabel.text }
    set { self.textLabel.text = newValue }
  }

  open var attributedText: NSAttributedString? {
    get { return self.textLabel.attributedText }
    set { self.textLabel.attributedText = newValue }
  }
  
  open var image: UIImage? {
    didSet {
      self.imageView.image = image
      self.setNeedsLayout()
    }
  }

  // MARK: Appearance

  /// The background view's color.
  override open dynamic var backgroundColor: UIColor? {
    get { return self.backgroundView.backgroundColor }
    set { self.backgroundView.backgroundColor = newValue }
  }

  /// The background view's corner radius.
  @objc open dynamic var cornerRadius: CGFloat {
    get { return self.backgroundView.layer.cornerRadius }
    set { self.backgroundView.layer.cornerRadius = newValue }
  }

  /// The inset of the text label.
  @objc open dynamic var textInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)

  /// The color of the text label's text.
  @objc open dynamic var textColor: UIColor? {
    get { return self.textLabel.textColor }
    set { self.textLabel.textColor = newValue }
  }

  /// The font of the text label.
  @objc open dynamic var font: UIFont? {
    get { return self.textLabel.font }
    set { self.textLabel.font = newValue }
  }

  /// The bottom offset from the screen's bottom in portrait mode.
  @objc open dynamic var bottomOffsetPortrait: CGFloat = {
    switch UIDevice.current.userInterfaceIdiom {
    // specific values
    case .phone: return 30
    case .pad: return 60
    case .tv: return 90
    case .carPlay: return 30
    case .mac: return 60
    case .vision: return 60
    // default values
    case .unspecified: fallthrough
    @unknown default: return 30
    }
  }()

  /// The bottom offset from the screen's bottom in landscape mode.
  @objc open dynamic var bottomOffsetLandscape: CGFloat = {
    switch UIDevice.current.userInterfaceIdiom {
    // specific values
    case .phone: return 20
    case .pad: return 40
    case .tv: return 60
    case .carPlay: return 20
    case .mac: return 40
    case .vision: return 40
    // default values
    case .unspecified: fallthrough
    @unknown default: return 20
    }
  }()
  
  /// If this value is `true` and SafeArea is available,
  /// `safeAreaInsets.bottom` will be added to the `bottomOffsetPortrait` and `bottomOffsetLandscape`.
  /// Default value: false
  @objc open dynamic var useSafeAreaForBottomOffset: Bool = false

  /// The width ratio of toast view in window, specified as a value from 0.0 to 1.0.
  /// Default value: 0.875
  @objc open dynamic var maxWidthRatio: CGFloat = (280.0 / 320.0)
  
  /// The shape of the layer’s shadow.
  @objc open dynamic var shadowPath: CGPath? {
    get { return self.layer.shadowPath }
    set { self.layer.shadowPath = newValue }
  }
  
  /// The color of the layer’s shadow.
  @objc open dynamic var shadowColor: UIColor? {
    get { return self.layer.shadowColor.flatMap { UIColor(cgColor: $0) } }
    set { self.layer.shadowColor = newValue?.cgColor }
  }
  
  /// The opacity of the layer’s shadow.
  @objc open dynamic var shadowOpacity: Float {
    get { return self.layer.shadowOpacity }
    set { self.layer.shadowOpacity = newValue }
  }
  
  /// The offset (in points) of the layer’s shadow.
  @objc open dynamic var shadowOffset: CGSize {
    get { return self.layer.shadowOffset }
    set { self.layer.shadowOffset = newValue }
  }
  
  /// The blur radius (in points) used to render the layer’s shadow.
  @objc open dynamic var shadowRadius: CGFloat {
    get { return self.layer.shadowRadius }
    set { self.layer.shadowRadius = newValue }
  }

  // MARK: UI

  private let backgroundView: UIView = {
    let `self` = UIView()
    self.backgroundColor = UIColor(white: 0, alpha: 0.7)
    self.layer.cornerRadius = 5
    self.clipsToBounds = true
    return self
  }()
  
  private let textLabel: UILabel = {
    let `self` = UILabel()
    self.textColor = .white
    self.backgroundColor = .clear
    self.font = {
      switch UIDevice.current.userInterfaceIdiom {
      // specific values
      case .phone: return .systemFont(ofSize: 12)
      case .pad: return .systemFont(ofSize: 16)
      case .tv: return .systemFont(ofSize: 20)
      case .carPlay: return .systemFont(ofSize: 12)
      case .mac: return .systemFont(ofSize: 16)
      case .vision: return .systemFont(ofSize: 16)
      // default values
      case .unspecified: fallthrough
      @unknown default: return .systemFont(ofSize: 12)
      }
    }()
    self.numberOfLines = 0
    self.textAlignment = .center
    return self
  }()
  
  private let imageView: UIImageView = {
    let `self` = UIImageView()
    self.contentMode = .scaleAspectFit
    return self
  }()


  // MARK: Initializing

  public init() {
    super.init(frame: .zero)
    self.isUserInteractionEnabled = true
    self.addSubview(self.backgroundView)
    self.addSubview(self.imageView)
    self.addSubview(self.textLabel)
    self.isExclusiveTouch = true // Prevent interaction with superview
  }

  required convenience public init?(coder aDecoder: NSCoder) {
    self.init()
  }


  // MARK: Layout

  override open func layoutSubviews() {
    super.layoutSubviews()

    let containerWidth = self.superview?.bounds.width
      ?? self.window?.bounds.width
      ?? ToastWindow.shared.frame.width
    let containerHeight = self.superview?.bounds.height
      ?? self.window?.bounds.height
      ?? ToastWindow.shared.frame.height
    guard containerWidth > 0, containerHeight > 0 else { return }

    let maxWidth = min(containerWidth * self.maxWidthRatio, containerWidth - 32)
    let imageViewSize = self.imageView.image != nil ? CGSize(width: 24, height: 24) : .zero
    let imageSpacing: CGFloat = imageViewSize.width > 0 ? 8 : 0
    let constraintSize = CGSize(
      width: max(0, maxWidth - self.textInsets.left - self.textInsets.right - imageViewSize.width - imageSpacing),
      height: CGFloat.greatestFiniteMagnitude
    )
    let textLabelSize = self.textLabel.sizeThatFits(constraintSize)
    let contentWidth = imageViewSize.width + imageSpacing + textLabelSize.width
    let totalWidth = min(maxWidth - self.textInsets.left - self.textInsets.right, contentWidth)
    let totalHeight = max(textLabelSize.height, imageViewSize.height)

    self.textLabel.textAlignment = imageViewSize.width > 0 ? .left : .center
    self.imageView.frame = CGRect(
      x: self.textInsets.left,
      y: self.textInsets.top + (totalHeight - imageViewSize.height) / 2,
      width: imageViewSize.width,
      height: imageViewSize.height
    )
    self.textLabel.frame = CGRect(
      x: self.textInsets.left + imageViewSize.width + imageSpacing,
      y: self.textInsets.top + (totalHeight - textLabelSize.height) / 2,
      width: min(textLabelSize.width, max(0, totalWidth - imageViewSize.width - imageSpacing)),
      height: textLabelSize.height
    )
    self.backgroundView.frame = CGRect(
      x: 0,
      y: 0,
      width: totalWidth + self.textInsets.left + self.textInsets.right,
      height: totalHeight + self.textInsets.top + self.textInsets.bottom
    )

    // Superview (key window) already matches interface orientation.
    // Do not swap width/height from statusBarOrientation — that places the toast mid-screen.
    let isPortrait = containerHeight >= containerWidth
    var bottomOffset = isPortrait ? self.bottomOffsetPortrait : self.bottomOffsetLandscape
    if #available(iOS 11.0, *), useSafeAreaForBottomOffset {
      bottomOffset += self.superview?.safeAreaInsets.bottom
        ?? self.window?.safeAreaInsets.bottom
        ?? ToastWindow.shared.safeAreaInsets.bottom
    }

    let backgroundViewSize = self.backgroundView.frame.size
    let x = (containerWidth - backgroundViewSize.width) / 2
    let y = containerHeight - backgroundViewSize.height - bottomOffset
    self.frame = CGRect(
      x: x,
      y: y,
      width: backgroundViewSize.width,
      height: backgroundViewSize.height
    )
  }

  override open func hitTest(_ point: CGPoint, with event: UIEvent!) -> UIView? {
    if self.point(inside: point, with: event) {
      return self
    }
    return nil
  }

  override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    return self.bounds.contains(point)
  }

}
