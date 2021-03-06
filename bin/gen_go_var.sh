#!/usr/bin/env xcrun swift

//
//  main.swift
//  h4Tools
//
//  Created by Michael Mellinger on 2/20/15.
//  Copyright (c) 2015 h4labs. All rights reserved.
//

import Foundation

let groupNumbers = [
    "sites": 1,
    "beginner" : 2,
    "tutorial" : 3,
    "source" : 4,
    "lib" : 5,
    "libs" : 5,
    "playground" : 6,
    "advanced" : 7,
    "commercial" : 8
]

class UrlRecord {
    var id: Int
    var groupNum: Int
    var source: String
    var url: String
    var title: String

    var tags: String
    var date: Int
    
    init(id: Int, groupNum: Int, source: String, url: String, title: String, tags: String, date: Int) {

        self.id = id
        self.groupNum = groupNum
        self.source = source
        self.url = url
        self.title = title
        self.tags = tags
        self.date = date
    }
}

var database:[UrlRecord] = []

func readLines(filePath: String) -> [String] {
    //    var stream:NSStream = NSStream
    
    var allLines:[String] = []
    
    if let fileManager =  NSFileManager.defaultManager() as NSFileManager! {
        let fileExists = fileManager.fileExistsAtPath(filePath)
        if fileExists {
            var data:NSData? = fileManager.contentsAtPath(filePath)
            //            let data0 = data
            let aString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //            println(aString)
            let str1:String = aString as String
            allLines = str1.componentsSeparatedByString("\n")
            
        } else {
            println("file not found: \(filePath)")
        }
        
        
    }
    return allLines
    
}

func writeGoVar(groupNum: Int, url: String, name: String,
    source: String, tags: String, date: Int) {
        
        let lowerTitle = name.lowercaseString
        println("{\(groupNum), \"\(url)\",\"\(name)\",\"\(lowerTitle)\" ,\"\(source)\", \"\(tags)\",\(date) },")
}

func deriveSource(url: String) -> String {
    
    var source = "n/a"
    var F:[String] // Translated from Perl?
    let F0 = url.componentsSeparatedByString("//")
    let url0:String = F0[1]
    F = url0.componentsSeparatedByString("/")
    if url.rangeOfString("github.com") != nil {
        source = "github.com/" + F[1]
        
    } else if url.hasPrefix("http") { //(url =~ m#^http://([a-zA-Z0-9.\-\!\#]*)/#) {
        
        source = F[0].stringByReplacingOccurrencesOfString("www.", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil) //  source =~ s/www[.]//;
    } else {
        source = url;
        //    source =~ s/http:\/\///;
        //    my @F = split(/\//, url);
        
        //    # my @F = split(source,'/');
        source = F[0];
    }
    return source
}

let lines = readLines("/tmp/swift_urls.tsv")
var allUrls:[String:Int] = [:]

var ok:Int
var i=1
for line in lines {
    //    ok = false
    if !(line.hasPrefix("#") || line.hasPrefix(" ")) {
        let aLine = line.componentsSeparatedByString("\t")
        if aLine.count > 1 {
            //        println(" { \"\(aLine[1])  ")
            
            if let groupNum = groupNumbers[aLine[0]] {
                let url = aLine[1]
                var source = deriveSource(url)
                // TODO: Check for trailing / and http vs https
                if let exists = allUrls[url] {
                    println("Error: Duplicate URL: \(url)")
                } else {
                    allUrls[url]=1
                }
                let title = aLine[2]
                let tags = aLine[3]
                var date:Int? = aLine[4].toInt()
                if (date == nil) {
                    date = 20010101
                }
                let rec = UrlRecord(id: i, groupNum: groupNum, source: source, url: url, title: title, tags: tags, date: date!)
                database.append(rec)

                
            } else {
                println("Error: Invalid Group: \(line)")
            }
        } else {
//            println("Error: Not enough values on line: \(line)")
        }
    }
    i++
}

database.sort({ (rec1, rec2) -> Bool in
    if rec1.groupNum < rec2.groupNum {
        return true
    } else if rec1.groupNum == rec2.groupNum {
        if rec1.source < rec2.source { // &&
            return true
        } else if rec1.source == rec2.source {
            if rec1.date > rec2.date { // most recent first
                return true
            }
        }
    }
    return false
    })

println("package webserver\n")
println(" var urlList = []SwiftRec{")

for row in database {
    writeGoVar(row.groupNum, row.url, row.title, row.source, row.tags, row.date)
}
println("}")

//for fileName in Process.arguments {
    //    cat(fileName)
    
//}


