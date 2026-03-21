//
//  Defaults.swift
//  TracyPlayer
//
//  Created by kintan on 2023/7/21.
//

import Foundation
import KSPlayer
import SwiftUI

@Observable public class Defaults {
    @ObservationIgnored
    @AppStorage("showRecentPlayList") public var showRecentPlayList = false

    @ObservationIgnored
    @AppStorage("hardwareDecode")
    public var hardwareDecode = KSOptions.hardwareDecode {
        didSet {
            KSOptions.hardwareDecode = hardwareDecode
        }
    }

    @ObservationIgnored
    @AppStorage("asynchronousDecompression")
    public var asynchronousDecompression = KSOptions.asynchronousDecompression {
        didSet {
            KSOptions.asynchronousDecompression = asynchronousDecompression
        }
    }

    @ObservationIgnored
    @AppStorage("isUseDisplayLayer")
    public var isUseDisplayLayer = MEOptions.isUseDisplayLayer {
        didSet {
            MEOptions.isUseDisplayLayer = isUseDisplayLayer
        }
    }

    @ObservationIgnored
    @AppStorage("preferredForwardBufferDuration")
    public var preferredForwardBufferDuration = KSOptions.preferredForwardBufferDuration {
        didSet {
            KSOptions.preferredForwardBufferDuration = preferredForwardBufferDuration
        }
    }

    @ObservationIgnored
    @AppStorage("maxBufferDuration")
    public var maxBufferDuration = KSOptions.maxBufferDuration {
        didSet {
            KSOptions.maxBufferDuration = maxBufferDuration
        }
    }

    @ObservationIgnored
    @AppStorage("isLoopPlay")
    public var isLoopPlay = KSOptions.isLoopPlay {
        didSet {
            KSOptions.isLoopPlay = isLoopPlay
        }
    }

    @ObservationIgnored
    @AppStorage("canBackgroundPlay")
    public var canBackgroundPlay = true {
        didSet {
            KSOptions.canBackgroundPlay = canBackgroundPlay
        }
    }

    @ObservationIgnored
    @AppStorage("isAutoPlay")
    public var isAutoPlay = true {
        didSet {
            KSOptions.isAutoPlay = isAutoPlay
        }
    }

    @ObservationIgnored
    @AppStorage("isSecondOpen")
    public var isSecondOpen = true {
        didSet {
            KSOptions.isSecondOpen = isSecondOpen
        }
    }

    @ObservationIgnored
    @AppStorage("isAccurateSeek")
    public var isAccurateSeek = true {
        didSet {
            KSOptions.isAccurateSeek = isAccurateSeek
        }
    }

    @ObservationIgnored
    @AppStorage("isPipPopViewController")
    public var isPipPopViewController = true {
        didSet {
            KSOptions.isPipPopViewController = isPipPopViewController
        }
    }

    @ObservationIgnored
    @AppStorage("textFontSize")
    public var textFontSize = SubtitleModel.textFontSize {
        didSet {
            SubtitleModel.textFontSize = textFontSize
        }
    }

    @ObservationIgnored
    @AppStorage("textBold")
    public var textBold = SubtitleModel.textBold {
        didSet {
            SubtitleModel.textBold = textBold
        }
    }

    @ObservationIgnored
    @AppStorage("textItalic")
    public var textItalic = SubtitleModel.textItalic {
        didSet {
            SubtitleModel.textItalic = textItalic
        }
    }

    @ObservationIgnored
    @AppStorage("textColor")
    public var textColor = SubtitleModel.textColor {
        didSet {
            SubtitleModel.textColor = textColor
        }
    }

    @ObservationIgnored
    @AppStorage("textBackgroundColor")
    public var textBackgroundColor = SubtitleModel.textBackgroundColor {
        didSet {
            SubtitleModel.textBackgroundColor = textBackgroundColor
        }
    }

    @ObservationIgnored
    @AppStorage("horizontalAlign")
    public var horizontalAlign = SubtitleModel.textPosition.horizontalAlign {
        didSet {
            SubtitleModel.textPosition.horizontalAlign = horizontalAlign
        }
    }

    @ObservationIgnored
    @AppStorage("verticalAlign")
    public var verticalAlign = SubtitleModel.textPosition.verticalAlign {
        didSet {
            SubtitleModel.textPosition.verticalAlign = verticalAlign
        }
    }

    @ObservationIgnored
    @AppStorage("leftMargin")
    public var leftMargin = SubtitleModel.textPosition.leftMargin {
        didSet {
            SubtitleModel.textPosition.leftMargin = leftMargin
        }
    }

    @ObservationIgnored
    @AppStorage("rightMargin")
    public var rightMargin = SubtitleModel.textPosition.rightMargin {
        didSet {
            SubtitleModel.textPosition.rightMargin = rightMargin
        }
    }

    @ObservationIgnored
    @AppStorage("verticalMargin")
    public var verticalMargin = SubtitleModel.textPosition.verticalMargin {
        didSet {
            SubtitleModel.textPosition.verticalMargin = verticalMargin
        }
    }

    @ObservationIgnored
    @AppStorage("yadifMode")
    public var yadifMode = MEOptions.yadifMode {
        didSet {
            MEOptions.yadifMode = yadifMode
        }
    }

    @ObservationIgnored
    @AppStorage("audioPlayerType")
    public var audioPlayerType = NSStringFromClass(KSOptions.audioPlayerType) {
        didSet {
            KSOptions.audioPlayerType = NSClassFromString(audioPlayerType) as! any AudioOutput.Type
        }
    }

    public static let shared = Defaults()
    private init() {
        KSOptions.hardwareDecode = hardwareDecode
        MEOptions.isUseDisplayLayer = isUseDisplayLayer
        SubtitleModel.textFontSize = textFontSize
        SubtitleModel.textBold = textBold
        SubtitleModel.textItalic = textItalic
        SubtitleModel.textColor = textColor
        SubtitleModel.textBackgroundColor = textBackgroundColor
        SubtitleModel.textPosition.horizontalAlign = horizontalAlign
        SubtitleModel.textPosition.verticalAlign = verticalAlign
        SubtitleModel.textPosition.leftMargin = leftMargin
        SubtitleModel.textPosition.rightMargin = rightMargin
        SubtitleModel.textPosition.verticalMargin = verticalMargin
        KSOptions.preferredForwardBufferDuration = preferredForwardBufferDuration
        KSOptions.maxBufferDuration = maxBufferDuration
        KSOptions.isLoopPlay = isLoopPlay
        KSOptions.canBackgroundPlay = canBackgroundPlay
        KSOptions.isAutoPlay = isAutoPlay
        KSOptions.isSecondOpen = isSecondOpen
        KSOptions.isAccurateSeek = isAccurateSeek
        KSOptions.isPipPopViewController = isPipPopViewController
        MEOptions.yadifMode = yadifMode
        KSOptions.audioPlayerType = NSClassFromString(audioPlayerType) as! any AudioOutput.Type
    }
}

@propertyWrapper
public struct Default<T>: DynamicProperty {
    private var defaults: Defaults
    private let keyPath: ReferenceWritableKeyPath<Defaults, T>
    public init(_ keyPath: ReferenceWritableKeyPath<Defaults, T>, defaults: Defaults = .shared) {
        self.keyPath = keyPath
        self.defaults = defaults
    }

    public var wrappedValue: T {
        get { defaults[keyPath: keyPath] }
        nonmutating set { defaults[keyPath: keyPath] = newValue }
    }

    public var projectedValue: Binding<T> {
        Binding(
            get: { defaults[keyPath: keyPath] },
            set: { value in
                defaults[keyPath: keyPath] = value
            }
        )
    }
}
