//
//  ScollContext.swift
//  ListKit
//
//  Created by Frain on 2019/12/16.
//

#if os(iOS) || os(tvOS)
import UIKit

public struct ScrollContext<Source: DataSource>: Context where Source.SourceBase == Source {
    public let listView: UIScrollView
    public let context: ListCoordinatorContext<Source>
}

#endif
