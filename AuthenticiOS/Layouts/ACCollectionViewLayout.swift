//
//  ACCollectionViewLayout.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 6/13/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit

protocol ACCollectionViewLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, sizeForCellAtIndexPath indexPath: IndexPath) -> CGSize
}

class ACCollectionViewLayout: UICollectionViewLayout {
    init(columns: Int, delegate: ACCollectionViewLayoutDelegate) {
        self.numberOfColumns = columns
        self.delegate = delegate
        super.init()
    }
    
    required init?(coder: NSCoder) {
        numberOfColumns = 1
        super.init(coder: coder)
    }
    
    weak var delegate: ACCollectionViewLayoutDelegate!
    
    fileprivate var numberOfColumns: Int
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    fileprivate var contentHeight: CGFloat = 0
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }
        cache.removeAll()
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let extraOffset = indexPath.item == 1 ? collectionView.frame.width / 2 : 0
            let size = delegate.collectionView(collectionView, sizeForCellAtIndexPath: indexPath)
            let frame = CGRect(x: xOffset[column], y: yOffset[column] + extraOffset, width: size.width, height: size.height)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + size.height + extraOffset
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
