//
//  SortByList.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/13/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation

class SortByList {
    
    static func getList() -> [ListItem] {
        
        //Map the order with 'SortIndex'
        var list: [ListItem] = []
        list.append(ListItem(name: "Added date"))
        list.append(ListItem(name: "Most Played"))
        list.append(ListItem(name: "Played date"))
        list.append(ListItem(name: "Size"))
        list.append(ListItem(name: "Length"))
        
        return list
    }
}


enum SortIndex: Int {
    case AddedDate, MostPlayed, PlayedDate, Size, Length
}
