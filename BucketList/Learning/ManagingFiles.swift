//
//  ManagingFiles.swift
//  BucketList
//
//  Created by RqwerKnot on 21/03/2022.
//

import SwiftUI

struct ManagingFiles: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onTapGesture {
                    let str = "Test Message"
                    print("Message written: \(str)")
                
                    let url = getDocumentsDirectory().appendingPathComponent("message.txt", isDirectory: false)

                    do {
                        // writing data using UTF8 encoding:
                        
                        // The first of those can be created by combining the documents directory URL with a filename, such as myfile.txt.
                        // The second should nearly always be set to true. If this is set to false and we try to write a big file, it’s possible that another part of our app might try and read the file while it’s still being written. This shouldn’t cause a crash or anything, but it does mean that it’s going to read only part of the data, because the other part hasn’t been written yet. Atomic writing causes the system to write our full file to a temporary filename (not the one we asked for), and when that’s finished it does a simple rename to our target filename. This means either the whole file is there or nothing is.
                        // The third parameter is something we looked at briefly in project 5, because we had to use a Swift string with an Objective-C API. Back then we used the character encoding UTF-16, which is what Objective-C uses, but Swift’s native encoding is UTF-8, so we’re going to use that instead.
                        try str.write(to: url, atomically: true, encoding: .utf8)
                        
                        // reading data as a Swift String (UTF8 by design) out of the given URL:
                        let input = try String(contentsOf: url)
                        print("message read: \(input)")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user (and for this app)
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

struct ManagingFiles_Previews: PreviewProvider {
    static var previews: some View {
        ManagingFiles()
    }
}
