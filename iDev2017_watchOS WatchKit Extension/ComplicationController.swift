//
//  ComplicationController.swift
//  iDev2017_watchOS WatchKit Extension
//
//  Created by Justin Domnitz on 7/11/17.
//  Copyright © 2017 Lowyoyo, LLC. All rights reserved.
//

import ClockKit

struct ComplicationConstants {
    static let CFASquareLogoCircularImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "ic_filter_1")!)
    static let CFASquareLogoModularImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "ic_filter_1")!)
    static let CFASquareLogoUtilitarianImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "ic_filter_1")!)
}

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let westerosCities = ["King's Landing",
                          "Oldtown",
                          "Lannisport",
                          "Gulltown",
                          "White Harbor"]
    
    let westerosRegions = ["Beyond the Wall",
                           "The North",
                           "The Iron Islands",
                           "The Riverlands",
                           "The Vale of Arryn",
                           "The Westerlands",
                           "The Crownlands",
                           "The Reach",
                           "The Stormlands",
                           "Dorne"]
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    // Unused types: CLKComplicationTemplateModularSmallRingImage, CLKComplicationTemplateModularSmallRingText,
    //               CLKComplicationTemplateModularSmallSimpleImage, CLKComplicationTemplateModularSmallSimpleText,
    //               CLKComplicationTemplateModularSmallStackImage, CLKComplicationTemplateModularSmallStackText
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        //Because we're in getCurrentTimelineEntryForComplication, we don't have to care what date
        //value is passed to the handler via the CLKComplicationTimelineEntry.  This value
        //is ignored and whatever data we send is *always* displayed *right now*.
        switch complication.family {
        case .modularSmall:
            if let template = getModularSmallTemplate() {
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
                return
            }
            
        case .modularLarge:
            if let template = getModularLargeTemplate() {
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
                return
            }
            
        case .utilitarianSmall:
            if let template = getUtilitarianSmallTemplate() {
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
                return
            }
            
        case .utilitarianSmallFlat:
            if let template = getUtilitarianSmallFlatTemplate() {
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
                return
            }
            break
            
        case .utilitarianLarge:
            if let template = getUtilitarianLargeTemplate() {
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
                return
            }
            
        case .circularSmall:
            if let template = getCircularSmallTemplate() {
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
                return
            }
            
        case .extraLarge:
            if let template = getExtraLargeTemplate() {
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
                return
            }
        }
        
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
    func getModularLargeTemplate() -> CLKComplicationTemplate? {
        let template = CLKComplicationTemplateModularLargeColumns()
        template.row1Column1TextProvider = CLKSimpleTextProvider(text: "King's"   , shortText: "King's" )
        template.row1Column2TextProvider = CLKSimpleTextProvider(text: ""         , shortText: ""     )
        template.row2Column1TextProvider = CLKSimpleTextProvider(text: "Landing"  , shortText: "Land"   )
        template.row2Column2TextProvider = CLKSimpleTextProvider(text: ""         , shortText: ""     )
        template.row3Column1TextProvider = CLKSimpleTextProvider(text: ""         , shortText: "ing"  )
        template.row3Column2TextProvider = CLKSimpleTextProvider(text: ""         , shortText: ""     )
        template.row1ImageProvider = ComplicationConstants.CFASquareLogoModularImageProvider
        template.column2Alignment = .trailing
        return template
    }
    
    func getModularSmallTemplate() -> CLKComplicationTemplate? {
        let template = CLKComplicationTemplateModularSmallColumnsText()
        template.row1Column1TextProvider = CLKSimpleTextProvider(text: "King's"   , shortText: "King's" )
        template.row1Column2TextProvider = CLKSimpleTextProvider(text: ""         , shortText: ""       )
        template.row2Column1TextProvider = CLKSimpleTextProvider(text: "Landing"  , shortText: "Land"   )
        template.row2Column2TextProvider = CLKSimpleTextProvider(text: ""         , shortText: ""       )
        return template
    }
    
    func getUtilitarianLargeTemplate() -> CLKComplicationTemplate? {
        let template = CLKComplicationTemplateUtilitarianLargeFlat()
        template.textProvider = CLKSimpleTextProvider(text:      "King's Landing",
                                                      shortText: "King's Land")
        template.imageProvider = ComplicationConstants.CFASquareLogoUtilitarianImageProvider
        return template
    }
    
    func getUtilitarianSmallTemplate() -> CLKComplicationTemplate? {
        let template = CLKComplicationTemplateUtilitarianSmallFlat()
        template.textProvider = CLKSimpleTextProvider(text: "King's", shortText: "Ki")
        return template
    }
    
    func getUtilitarianSmallFlatTemplate() -> CLKComplicationTemplate? {
        let template = CLKComplicationTemplateUtilitarianSmallFlat()
        template.textProvider = CLKSimpleTextProvider(text: "King's", shortText: "Ki")
        return template
    }
    
    func getCircularSmallTemplate() -> CLKComplicationTemplate? {
        let template = CLKComplicationTemplateCircularSmallRingImage()
        template.imageProvider = ComplicationConstants.CFASquareLogoCircularImageProvider
        template.ringStyle = .closed
        return template
    }
    
    func getExtraLargeTemplate() -> CLKComplicationTemplate? {
        let template = CLKComplicationTemplateModularLargeColumns()
        template.row1Column1TextProvider = CLKSimpleTextProvider(text: "King's"   , shortText: "King's" )
        template.row1Column2TextProvider = CLKSimpleTextProvider(text: ""         , shortText: ""       )
        template.row2Column1TextProvider = CLKSimpleTextProvider(text: "Landing"  , shortText: "Land"   )
        template.row2Column2TextProvider = CLKSimpleTextProvider(text: ""         , shortText: ""       )
        template.row3Column1TextProvider = CLKSimpleTextProvider(text: ""         , shortText: "ing"    )
        template.row3Column2TextProvider = CLKSimpleTextProvider(text: ""         , shortText: ""       )
        template.row1ImageProvider = ComplicationConstants.CFASquareLogoModularImageProvider
        template.column2Alignment = .trailing
        return template
    }
    
}

