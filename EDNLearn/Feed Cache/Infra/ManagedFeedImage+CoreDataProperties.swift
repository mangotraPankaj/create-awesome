//
//  ManagedFeedImage+CoreDataProperties.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 24/08/21.
//
//

import CoreData
import Foundation

public extension ManagedFeedImage {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ManagedFeedImage> {
        return NSFetchRequest<ManagedFeedImage>(entityName: "ManagedFeedImage")
    }

    @NSManaged var id: UUID?
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL?
    @NSManaged var cache: ManagedCache?
}
