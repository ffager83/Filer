//
//  Filer.swift
//  Filer
//
//  Created by Takuma Yoshida on 2015/07/13.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation

public class Filer {
    // MARK: static methods
    public static func withDir <T> (directory: StoreDirectory, f: (String, NSFileManager) -> T) -> T {
        let writePath = directory.path()
        let fileManager = NSFileManager.defaultManager()
        return f(writePath, fileManager)
    }

    public static func mkdir(directory: StoreDirectory, dirName: String) -> Bool {
        return withDir(directory) { path, manager in
            let path = "\(path)/\(dirName)"
            do {
                try manager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch _ {
                return false
            }
        }
    }

    public static func touch(directory: StoreDirectory, path: String) -> Bool {
        return FileWriter(file: File(directory: directory, path: path)).write("")
    }

    public static func rm(directory: StoreDirectory, path: String) -> Bool {
        return withDir(directory) { dirPath, manager in
            let filePath = "\(dirPath)/\(path)"
            do {
                try manager.removeItemAtPath(filePath)
                return true
            } catch _ {
                return false
            }
        }
    }

    public static func mv(directory: StoreDirectory, srcPath: String, toPath: String) -> Bool {
        return withDir(directory) { path, manager in
            let from = "\(path)/\(srcPath)"
            let to = "\(path)/\(toPath)"
            do {
                try manager.moveItemAtPath(from, toPath: to)
                return true
            } catch _ {
                return false
            }
        }
    }

    public static func rmdir(directory: StoreDirectory, dirName: String) -> Bool {
        return rm(directory, path: dirName)
    }

    public static func cp(directory: StoreDirectory, srcPath: String, toPath: String) -> Bool {
        return withDir(directory) { path, manager in
            let from = "\(path)/\(srcPath)"
            let to = "\(path)/\(toPath)"
            do {
                try manager.copyItemAtPath(from, toPath: to)
                return true
            } catch _ {
                return false
            }
        }
    }

    public static func test(directory: StoreDirectory, path: String) -> Bool {
        return withDir(directory) { dirPath, manager in
            let path = "\(dirPath)/\(path)"
            return manager.fileExistsAtPath(path)
        }
    }

    public static func exists(directory: StoreDirectory, path: String) -> Bool {
        return test(directory, path: path)
    }

    public static func ls(directory: StoreDirectory, dir: String = "") -> [File]? {
        return withDir(directory) { dirPath, manager in
            let path = "\(dirPath)/\(dir)"
            return (try? manager.contentsOfDirectoryAtPath(path))?.map { "\(dir)/\($0 )" }
                .map { path in File(directory: directory, path: path) }
        }
    }

    public static func cat(directory: StoreDirectory, path: String) -> String {
        return File(directory: directory, path: path).read()
    }

    public static func du(directory: StoreDirectory, path: String) -> UInt64 {
        return withDir(directory) { dirPath, manager in
            let path = "\(dirPath)/\(path)"
            if let item: NSDictionary = try? manager.attributesOfItemAtPath(path) {
                return item.fileSize()
            }
            return 0
        }
    }
}
