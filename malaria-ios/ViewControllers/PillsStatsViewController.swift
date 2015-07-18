import Foundation
import UIKit
import QuartzCore

import Charts

class AdherenceHorizontalBarCell: UITableViewCell {
    
    let LowAdherenceColor = UIColor(red: 0.894, green: 0.429, blue: 0.442, alpha: 1.0)
    let HighAdherenceColor = UIColor(red: 0.374, green: 0.609, blue: 0.574, alpha: 1.0)
    
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var adherenceValue: UILabel!
    
    
    var setup = false
    func configureCell(date: NSDate, adhrenceValue: Float) -> AdherenceHorizontalBarCell{
        if !setup{
            slider.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 8)
            slider.setThumbImage(UIImage(), forState: UIControlState.Normal)
            slider.maximumTrackTintColor = UIColor.whiteColor()
            setup = true
        }
        
        slider.minimumTrackTintColor = adhrenceValue < 50 ? LowAdherenceColor : HighAdherenceColor
        slider.value = adhrenceValue
        month.text = (date.formatWith("MMM") as NSString).substringToIndex(3).capitalizedString
        adherenceValue.text = "\(Int(adhrenceValue))%"
        
        return self
    }
}

class PillsStatsViewController : UIViewController {
    
    @IBOutlet weak var adherenceSliderTable: UITableView!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var graphFrame: UIView!
    
    var viewContext: NSManagedObjectContext!
    var graphData: GraphData!
    
    let TextFont = UIFont(name: "AmericanTypewriter", size: 11.0)!
    let NoDataText = "There are no entries yet"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adherenceSliderTable.delegate = self
        adherenceSliderTable.dataSource = self
        adherenceSliderTable.backgroundColor = UIColor.clearColor()
        
        graphFrame.layer.cornerRadius = 20
        graphFrame.layer.masksToBounds = true
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewContext = CoreDataHelper.sharedInstance.createBackgroundContext()!
        
        chartView.clear()
        
        
        graphData = GraphData(context: viewContext)
        graphData.retrieveMonthsData(4){
            self.adherenceSliderTable.reloadData()
        }
        
        graphData.retrieveGraphData(){
            self.setChart(self.graphData.days, values: self.graphData.adherencesPerDay)
        }
    }
}

extension PillsStatsViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return graphData.months.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let month = graphData.months[indexPath.row]
        let adherenceValue = graphData.statsManager.pillAdherence(month)*100
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AdherenceHorizontalBarCell") as! AdherenceHorizontalBarCell
        cell.configureCell(month, adhrenceValue: adherenceValue)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let monthView = UIStoryboard.instantiate(viewControllerClass: MonthlyViewController.self)
        monthView.startDay = graphData.months[indexPath.row]
        monthView.data = graphData
        
        presentViewController(
            monthView,
            animated: true,
            completion: nil
        )
        
    }
}

extension PillsStatsViewController{
    /* Graph View related methods */
    
    
    func setChart(dataPoints: [NSDate], values: [Float]) {
        var dataPointsLabels = dataPoints.map({ $0.formatWith("yyyy.MM.dd")})

        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let adherenceData = configureCharDataSet(dataEntries, label: "")
        let data = LineChartData(xVals: dataPointsLabels, dataSets: [adherenceData])
        
        configureCharView(data)
        configureLegend()
        configureXAxis()
        configureLeftYAxis()
        configureRightYAxis()
    }
    
    func configureCharDataSet(dataEntries: [ChartDataEntry], label: String) -> ChartDataSet{
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: label)
        lineChartDataSet.colors = [UIColor.clearColor()]
        lineChartDataSet.drawFilledEnabled = true
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        
        lineChartDataSet.fillColor = UIColor.fromHex(0xA1D4E2)
        lineChartDataSet.fillAlpha = 1
        
        return lineChartDataSet
    }
    
    func configureLegend(){
        chartView.legend.enabled = false
    }
    
    
    func configureCharView(data: LineChartData){
        chartView.descriptionText = ""
        chartView.noDataText = NoDataText
        
        chartView.scaleYEnabled = false
        chartView.doubleTapToZoomEnabled = false
        
        chartView.data = data
        chartView.drawGridBackgroundEnabled = false
        chartView.highlightEnabled = false
        chartView.highlightIndicatorEnabled = false
    }
    
    func configureXAxis(){
        chartView.xAxis.labelPosition = .Bottom
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelTextColor = UIColor.fromHex(0x705246)
        chartView.xAxis.labelFont = TextFont
        chartView.xAxis.axisLineColor = UIColor.fromHex(0x8A8B8A)
        chartView.xAxis.axisLineWidth = 1.0
        chartView.xAxis.avoidFirstLastClippingEnabled = false
    }
    
    func configureRightYAxis(){
        chartView.rightAxis.axisLineColor = UIColor(red: 0.894, green: 0.429, blue: 0.442, alpha: 1.0)
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
        chartView.rightAxis.axisLineWidth = 1.0
    }
    
    func configureLeftYAxis(){
        chartView.leftAxis.axisLineColor = UIColor.fromHex(0x8A8B8A)
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.axisLineWidth = 1.0
        chartView.leftAxis.customAxisMin = 0
        chartView.leftAxis.customAxisMax = 100
        chartView.leftAxis.labelFont = TextFont
        chartView.leftAxis.labelTextColor = UIColor.fromHex(0x705246)
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.PercentStyle
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.multiplier = 1
        
        chartView.leftAxis.valueFormatter = numberFormatter
    }
}