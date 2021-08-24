//
//  ManagedCache+CoreDataProperties.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 24/08/21.
//
//

import CoreData
import Foundation

public extension ManagedCache {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ManagedCache> {
        return NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
    }

    @NSManaged var timestamp: Date?
    @NSManaged var feed: NSOrderedSet?
}

// MARK: Generated accessors for feed

public extension ManagedCache {
    @objc(insertObject:inFeedAtIndex:)
    @NSManaged func insertIntoFeed(_ value: ManagedFeedImage, at idx: Int)

    @objc(removeObjectFromFeedAtIndex:)
    @NSManaged func removeFromFeed(at idx: Int)

    @objc(insertFeed:atIndexes:)
    @NSManaged func insertIntoFeed(_ values: [ManagedFeedImage], at indexes: NSIndexSet)

    @objc(removeFeedAtIndexes:)
    @NSManaged func removeFromFeed(at indexes: NSIndexSet)

    @objc(replaceObjectInFeedAtIndex:withObject:)
    @NSManaged func replaceFeed(at idx: Int, with value: ManagedFeedImage)

    @objc(replaceFeedAtIndexes:withFeed:)
    @NSManaged func replaceFeed(at indexes: NSIndexSet, with values: [ManagedFeedImage])

    @objc(addFeedObject:)
    @NSManaged func addToFeed(_ value: ManagedFeedImage)

    @objc(removeFeedObject:)
    @NSManaged func removeFromFeed(_ value: ManagedFeedImage)

    @objc(addFeed:)
    @NSManaged func addToFeed(_ values: NSOrderedSet)

    @objc(removeFeed:)
    @NSManaged func removeFromFeed(_ values: NSOrderedSet)
}
