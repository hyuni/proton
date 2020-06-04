//
//  EditorListsSnapshotTests.swift
//  ProtonTests
//
//  Created by Rajdeep Kwatra on 31/5/20.
//  Copyright © 2020 Rajdeep Kwatra. All rights reserved.
//

import Foundation
import XCTest
import SnapshotTesting

import Proton

class EditorListsSnapshotTests: XCTestCase {
    let listCommand = ListCommand()
    let listTextProcessor = ListTextProcessor()
    var recordMode = false

    override func setUp() {
        super.setUp()
//        recordMode = true
    }

    func testInitiatesCreationOfList() {
        let viewController = EditorTestViewController()
        let editor = viewController.editor
        editor.selectedRange = .zero
        listCommand.execute(on: editor)
        viewController.render()

        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)
    }

    func testCreatesListFromSelectedText() {
        let text = """
        This is line 1. This is line 1. This is line 1. This is line 1.
        This is line 2.
        This is line 3. This is line 3. This is line 3. This is line 3.
        """

        let viewController = EditorTestViewController()
        let editor = viewController.editor
        editor.attributedText = NSAttributedString(string: text)
        editor.selectedRange = editor.attributedText.fullRange
        listCommand.execute(on: editor)

        viewController.render(size: CGSize(width: 300, height: 175))

        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)
    }

    func testIndentsAndOutdentsListWithoutSelectedRangeInBeginning() {
        // TODO: FIX - this is broken

        let text = """
        This is line 1. This is line 1. This is line 1. This is line 1.
        This is line 2.
        This is line 3. This is line 3. This is line 3. This is line 3.
        """

        let viewController = EditorTestViewController()
        let editor = viewController.editor
        editor.sequenceGenerators = [NumericSequenceGenerator(), DiamondBulletSequenceGenerator()]
        editor.attributedText = NSAttributedString(string: text)
        editor.selectedRange = editor.attributedText.fullRange
        listCommand.execute(on: editor)

        let secondLine = editor.contentLinesInRange(editor.attributedText.fullRange)[1]
        let rangeToSet = NSRange(location: secondLine.range.location, length: 0)
        editor.selectedRange = rangeToSet

        // Indent second line
            listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [], range: editor.selectedRange)
        viewController.render(size: CGSize(width: 300, height: 175))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)

        // Outdent second line
        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [.shift], range: editor.selectedRange)
        viewController.render(size: CGSize(width: 300, height: 175))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)
    }

    func testIndentsAndOutdentsListWithoutSelectedRangeInEnd() {
        let text = """
        This is line 1. This is line 1. This is line 1. This is line 1.
        This is line 2.
        This is line 3. This is line 3. This is line 3. This is line 3.
        """

        let viewController = EditorTestViewController()
        let editor = viewController.editor
        editor.sequenceGenerators = [NumericSequenceGenerator(), DiamondBulletSequenceGenerator()]
        editor.attributedText = NSAttributedString(string: text)
        editor.selectedRange = editor.attributedText.fullRange
        listCommand.execute(on: editor)

        let secondLine = editor.contentLinesInRange(editor.attributedText.fullRange)[1]
        let rangeToSet = NSRange(location: secondLine.range.endLocation, length: 0)
        editor.selectedRange = rangeToSet

        // Indent second line
            listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [], range: editor.selectedRange)
        viewController.render(size: CGSize(width: 300, height: 175))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)

        // Outdent second line
        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [.shift], range: editor.selectedRange)
        viewController.render(size: CGSize(width: 300, height: 175))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)
    }

    func testIndentsAndOutdentsListWithoutSelectedRangeInMiddle() {
           let text = """
           This is line 1. This is line 1. This is line 1. This is line 1.
           This is line 2.
           This is line 3. This is line 3. This is line 3. This is line 3.
           """

           let viewController = EditorTestViewController()
           let editor = viewController.editor
           editor.sequenceGenerators = [NumericSequenceGenerator(), DiamondBulletSequenceGenerator()]
           editor.attributedText = NSAttributedString(string: text)
           editor.selectedRange = editor.attributedText.fullRange
           listCommand.execute(on: editor)

           let secondLine = editor.contentLinesInRange(editor.attributedText.fullRange)[1]
           let rangeToSet = NSRange(location: secondLine.range.location, length: 4)
           editor.selectedRange = rangeToSet

           // Indent second line
               listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [], range: editor.selectedRange)
           viewController.render(size: CGSize(width: 300, height: 175))
           assertSnapshot(matching: viewController.view, as: .image, record: recordMode)

           // Outdent second line
           listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [.shift], range: editor.selectedRange)
           viewController.render(size: CGSize(width: 300, height: 175))
           assertSnapshot(matching: viewController.view, as: .image, record: recordMode)
       }

    func testIndentsAndOutdentsListWithMultipleSelectedLines() {
        let text = """
        This is line 1. This is line 1. This is line 1. This is line 1.
        This is line 2.
        This is line 3. This is line 3. This is line 3. This is line 3.
        """

        let viewController = EditorTestViewController()
        let editor = viewController.editor
        editor.sequenceGenerators = [NumericSequenceGenerator(), DiamondBulletSequenceGenerator()]
        editor.attributedText = NSAttributedString(string: text)
        editor.selectedRange = editor.attributedText.fullRange
        listCommand.execute(on: editor)

        let secondLine = editor.contentLinesInRange(editor.attributedText.fullRange)[1]

        let secondAndThirdLineRange = NSRange(location: secondLine.range.location, length: editor.contentLength - secondLine.range.location)

        // Indent second line
        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [], range: secondAndThirdLineRange)
        viewController.render(size: CGSize(width: 300, height: 175))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)

        // Outdent second line
        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [.shift], range: secondAndThirdLineRange)
        viewController.render(size: CGSize(width: 300, height: 175))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)
    }

    func testCreatesNewListItemOnReturnKey() {
        let text = "Test line."

        let viewController = EditorTestViewController()
        let editor = viewController.editor
        editor.sequenceGenerators = [NumericSequenceGenerator(), DiamondBulletSequenceGenerator()]
        editor.attributedText = NSAttributedString(string: text)
        editor.selectedRange = editor.attributedText.fullRange
        listCommand.execute(on: editor)
        editor.selectedRange = editor.textEndRange
        let attrs = editor.attributedText.attributes(at: editor.contentLength - 1, effectiveRange: nil)
        editor.appendCharacters(NSAttributedString(string: "\n", attributes: attrs))

        viewController.render(size: CGSize(width: 300, height: 175))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)
    }

    func testExitsNewListItemOnSecondReturnKey() {
        let text = "Test line."

        let viewController = EditorTestViewController()
        let editor = viewController.editor
        editor.sequenceGenerators = [NumericSequenceGenerator(), DiamondBulletSequenceGenerator()]
        editor.attributedText = NSAttributedString(string: text)
        editor.selectedRange = editor.attributedText.fullRange
        listCommand.execute(on: editor)
        editor.selectedRange = editor.textEndRange
        let attrs = editor.attributedText.attributes(at: editor.contentLength - 1, effectiveRange: nil)
        editor.appendCharacters(NSAttributedString(string: "\n", attributes: attrs))

        var editedRange = NSRange(location: editor.contentLength - 1, length: 1)
        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .enter, modifierFlags: [], range: editedRange)
        listTextProcessor.didProcess(editor: editor) // invoke lifecycle event manually
        viewController.render(size: CGSize(width: 300, height: 175))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)

        editor.appendCharacters(NSAttributedString(string: "\n", attributes: attrs))
        editedRange = NSRange(location: editor.contentLength - 1, length: 1)
        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .enter, modifierFlags: [], range: editedRange)
        listTextProcessor.didProcess(editor: editor) // invoke lifecycle event manually
        viewController.render(size: CGSize(width: 300, height: 175))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)
    }

    func testCreatesNewListItemOnSecondReturnKeyWhenInMiddleOfAList() {
        let text = """
               This is line 1.
               This is line 2.
               This is line 3.
               """

        let viewController = EditorTestViewController()
        let editor = viewController.editor
        editor.sequenceGenerators = [NumericSequenceGenerator(), DiamondBulletSequenceGenerator()]
        editor.attributedText = NSAttributedString(string: text)
        editor.selectedRange = editor.attributedText.fullRange
        listCommand.execute(on: editor)

        let secondLine = editor.contentLinesInRange(editor.attributedText.fullRange)[1]
        let rangeToSet = NSRange(location: secondLine.range.location, length: 0)
        editor.selectedRange = rangeToSet

        // Indent second line
        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [], range: editor.selectedRange)
        viewController.render(size: CGSize(width: 300, height: 175))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)

        let location = secondLine.range.endLocation
        let attrs = editor.attributedText.attributes(at: location - 1, effectiveRange: nil)
        editor.replaceCharacters(in: NSRange(location: location, length: 0), with: NSAttributedString(string: "\n", attributes: attrs))

        var editedRange = NSRange(location: location, length: 1)
        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .enter, modifierFlags: [], range: editedRange)
        listTextProcessor.didProcess(editor: editor) // invoke lifecycle event manually
        viewController.render(size: CGSize(width: 300, height: 175))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)

        editor.replaceCharacters(in: NSRange(location: location, length: 0), with: NSAttributedString(string: "\n", attributes: attrs))
        editedRange = NSRange(location: location + 1, length: 1)
        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .enter, modifierFlags: [], range: editedRange)
        listTextProcessor.didProcess(editor: editor) // invoke lifecycle event manually
        viewController.render(size: CGSize(width: 300, height: 175))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)
    }

    func testAddsMultipleLevelOfLists() {
        let text = "Test line.\n"

        let viewController = EditorTestViewController()
        let editor = viewController.editor
        editor.sequenceGenerators = [NumericSequenceGenerator(), DiamondBulletSequenceGenerator(), SquareBulletSequenceGenerator()]
        editor.attributedText = NSAttributedString(string: text)
        editor.selectedRange = editor.attributedText.fullRange
        listCommand.execute(on: editor)

        for _ in 0..<9 {
            var range = NSRange(location: editor.contentLength - 1, length: 1)
            listTextProcessor.handleKeyWithModifiers(editor: editor, key: .enter, modifierFlags: [], range: range)
            range = editor.textEndRange//NSRange(location: editor.contentLength - 1, length: 1)
            listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [], range: range)
            let attrs = editor.attributedText.attributes(at: editor.contentLength - 1, effectiveRange: nil)
            editor.appendCharacters(NSAttributedString(string: text, attributes: attrs))
        }

        viewController.render(size: CGSize(width: 400, height: 420))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)
    }

    func testOutdentsNestedItems() {
        let text = """
        Line 1
        Line 2
        Line 2a

        Line 2a1

        Line 2a2
        Line 3
        """

        let viewController = EditorTestViewController()
        let editor = viewController.editor
        editor.sequenceGenerators = [NumericSequenceGenerator(), DiamondBulletSequenceGenerator()]
        editor.attributedText = NSAttributedString(string: text)
        editor.selectedRange = editor.attributedText.fullRange
        listCommand.execute(on: editor)

        viewController.render(size: CGSize(width: 300, height: 225))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)

        let line2a = editor.contentLinesInRange(editor.attributedText.fullRange)[2]
        let line2a1 = editor.contentLinesInRange(editor.attributedText.fullRange)[4]
        let line2a2 = editor.contentLinesInRange(editor.attributedText.fullRange)[6]

        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [], range: NSRange(location: line2a.range.location, length: line2a2.range.endLocation - line2a.range.location))

        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [], range: line2a1.range)


        viewController.render(size: CGSize(width: 300, height: 225))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)

        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [.shift], range: line2a.range)
        viewController.render(size: CGSize(width: 300, height: 225))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)
    }

    func testIndentsNestedItems() {
        let text = """
        Line 1
        Line 2
        Line 2a

        Line 2a1

        Line 2a2
        Line 3
        """

        let viewController = EditorTestViewController()
        let editor = viewController.editor
        editor.sequenceGenerators = [NumericSequenceGenerator(), DiamondBulletSequenceGenerator()]
        editor.attributedText = NSAttributedString(string: text)
        editor.selectedRange = editor.attributedText.fullRange
        listCommand.execute(on: editor)

        viewController.render(size: CGSize(width: 300, height: 225))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)

        let line2 = editor.contentLinesInRange(editor.attributedText.fullRange)[1]
        let line2a = editor.contentLinesInRange(editor.attributedText.fullRange)[2]
        let line2a2 = editor.contentLinesInRange(editor.attributedText.fullRange)[6]


        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [], range: NSRange(location: line2a.range.location, length: line2a2.range.endLocation - line2a.range.location))

        viewController.render(size: CGSize(width: 300, height: 225))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)

        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [], range: line2.range)
        viewController.render(size: CGSize(width: 300, height: 225))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)
    }

    func testOutdentsToZerothLevel() {
        let text = """
        a
        b
        c
        d
        e
        """

        let viewController = EditorTestViewController()
        let editor = viewController.editor
        editor.sequenceGenerators = [NumericSequenceGenerator(), DiamondBulletSequenceGenerator()]
        editor.attributedText = NSAttributedString(string: text)
        editor.selectedRange = editor.attributedText.fullRange
        listCommand.execute(on: editor)

        let lines = editor.contentLinesInRange(editor.attributedText.fullRange)
        for i in 0..<lines.count {
            for _ in 0...i {
                listTextProcessor.handleKeyWithModifiers(editor: editor, key: .tab, modifierFlags: [], range: lines[i].range)
            }
        }

        viewController.render(size: CGSize(width: 300, height: 400))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)

        let paraStyle = editor.attributedText.attribute(.paragraphStyle, at: editor.textEndRange.location - 1, effectiveRange: nil) ?? NSParagraphStyle()

        editor.appendCharacters(NSAttributedString(string: "\n",
                                                   attributes: [
                                                    .paragraphStyle: paraStyle,
                                                    .listItem: 1]))
        editor.selectedRange =  NSRange(location: editor.textEndRange.location, length: 0)

        listTextProcessor.handleKeyWithModifiers(editor: editor, key: .enter, modifierFlags: [], range: NSRange(location: editor.textEndRange.location - 1, length: 1))
        listTextProcessor.didProcess(editor: editor)

        viewController.render(size: CGSize(width: 300, height: 400))
        assertSnapshot(matching: viewController.view, as: .image, record: recordMode)

        for _ in 0..<lines.count {
            editor.selectedRange =  NSRange(location: editor.textEndRange.location, length: 0)
            let paraStyle = editor.attributedText.attribute(.paragraphStyle, at: editor.textEndRange.location - 1, effectiveRange: nil) ?? NSParagraphStyle()
            editor.appendCharacters(NSAttributedString(string: "\n", attributes: [.paragraphStyle: paraStyle, .listItem: 1]))
            listTextProcessor.handleKeyWithModifiers(editor: editor, key: .enter, modifierFlags: [], range: NSRange(location: editor.textEndRange.location - 1, length: 1))
            listTextProcessor.didProcess(editor: editor)

            viewController.render(size: CGSize(width: 300, height: 400))
            assertSnapshot(matching: viewController.view, as: .image, record: recordMode)
        }
    }
}
