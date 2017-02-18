/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import XCTest
import TestSupport
import Basic
import Utility

class BuildPerfTests: XCTestCasePerf {
    let resources = Resources()

    @discardableResult
    func execute(args: [String] = [], chdir: AbsolutePath) throws -> String {
        // FIXME: We should pass the SWIFT_EXEC at lower level.
        return try SwiftPMProduct.SwiftBuild.execute(args + [], chdir: chdir, env: ["SWIFT_EXEC": resources.swiftCompiler.asString], printIfError: true)
    }

    func clean(chdir: AbsolutePath) throws {
        _ = try SwiftPMProduct.SwiftPackage.execute(["clean"], chdir: chdir)
    }

    func testTrivialPackageFullBuild() {
        runFullBuildTest(for: "DependencyResolution/Internal/Simple", product: "foo")
    }

    func testTrivialPackageNullBuild() {
        runNullBuildTest(for: "DependencyResolution/Internal/Simple", product: "foo")
    }

    func testComplexPackageFullBuild() {
        runFullBuildTest(for: "DependencyResolution/External/Complex", app: "app", product: "Dealer")
    }

    func testComplexPackageNullBuild() {
        runNullBuildTest(for: "DependencyResolution/External/Complex", app: "app", product: "Dealer")
    }

    func runFullBuildTest(for name: String, app appString: String? = nil, product productString: String) {
        fixture(name: name) { prefix in
            let app = prefix.appending(components: (appString ?? ""))
            let product = app.appending(components: ".build", "debug", productString)
            try self.execute(chdir: app)
            measure {
                try! self.clean(chdir: app)
                try! self.execute(chdir: app)
                XCTAssertFileExists(product)
            }
        }
    }

    func runNullBuildTest(for name: String, app appString: String? = nil, product productString: String) {
        fixture(name: name) { prefix in
            let app = prefix.appending(components: (appString ?? ""))
            let product = app.appending(components: ".build", "debug", productString)
            try self.execute(chdir: app)
            measure {
                try! self.execute(chdir: app)
                XCTAssertFileExists(product)
            }
        }
    }
}
