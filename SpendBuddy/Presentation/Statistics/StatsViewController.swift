//
//  StatsViewController.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 18.10.25.
//

import UIKit
import SnapKit
import DGCharts

final class StatsViewController: BaseViewController {
    
    private let vm: StatsViewModel
    
    private let scroll: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 24, right: 16)
        return stack
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let pieCard = UIView()
    private let pieTitle: UILabel = {
        let label = UILabel()
        label.text = "By Category"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white.withAlphaComponent(0.9)
        return label
    }()
    private lazy var pie: PieChartView = {
        let pie = PieChartView()
        pie.delegate = self
        return pie
    }()
    
    private let barCard = UIView()
    private let barTitle: UILabel = {
        let label = UILabel()
        label.text = " By Day"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white.withAlphaComponent(0.9)
        return label
    }()
    private let bar = BarChartView()
    
    init(viewModel: StatsViewModel) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Statistics"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupUI()
        configureCharts()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Task { [weak self] in
            await self?.reloadData()
        }
    }
    
    private func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
                    .foregroundColor: UIColor.systemIndigo,
                    .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
                ]
        appearance.backgroundColor = .clear
        navigationItem.standardAppearance = appearance
    }
    
    private func setupUI() {
        view.addSubview(scroll)
        scroll.addSubview(contentStack)
        
        [monthLabel, pieCard, barCard].forEach(contentStack.addArrangedSubview)
        
        
        scroll.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentStack.snp.makeConstraints { make in
            make.edges.equalTo(scroll.contentLayoutGuide)
            make.width.equalTo(scroll.frameLayoutGuide)
        }
        
        pie.snp.makeConstraints { make in
            make.height.equalTo(260)
        }
        
        bar.snp.makeConstraints { make in
            make.height.equalTo(260)
        }
        
        [pieCard, barCard].forEach {
            $0.backgroundColor = .white.withAlphaComponent(0.06)
            $0.layer.cornerRadius = 14
            $0.layer.masksToBounds = true
        }
        
        let pieContainer = UIStackView(arrangedSubviews: [pieTitle, pie])
        pieContainer.axis = .vertical
        pieContainer.spacing = 8
        pieCard.addSubview(pieContainer)
        pieContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        let barContainer = UIStackView(arrangedSubviews: [barTitle, bar])
        barContainer.axis = .vertical
        barContainer.spacing = 8
        barCard.addSubview(barContainer)
        barContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    private func configureCharts() {
        
        pie.legend.enabled = false
        pie.drawEntryLabelsEnabled = true
        pie.holeRadiusPercent = 0.5
        pie.transparentCircleRadiusPercent = 0.55
        pie.holeColor = .clear
        pie.centerText = ""
        pie.highlightPerTapEnabled = true
        pie.rotationAngle = 0
        
        bar.rightAxis.enabled = false
        bar.legend.enabled = false
        bar.doubleTapToZoomEnabled = false
        bar.scaleXEnabled = false
        bar.scaleYEnabled = false
        bar.highlightPerTapEnabled = true
        bar.backgroundColor = .clear
        
        let x = bar.xAxis
        x.labelPosition = .bottom
        x.labelTextColor = .white.withAlphaComponent(0.8)
        x.axisLineColor = .clear
        x.gridColor = .white.withAlphaComponent(0.1)
        x.granularity = 1
        
        let y = bar.leftAxis
        y.labelTextColor = .white.withAlphaComponent(0.8)
        y.gridColor = .white.withAlphaComponent(0.1)
        y.axisLineColor = .clear
        
        
    }
    
    @MainActor
    private func reloadData() async {
        await vm.loadCurrentMonth()
        monthLabel.text = vm.monthTitle
        
        let total = vm.categorySlices.reduce(0) { $0 + $1.total }
        if total > 0 {
            let entries = vm.categorySlices.map { slice in
                PieChartDataEntry(value: slice.total, label: slice.category.title)
            }
            let set = PieChartDataSet(entries: entries, label: "")
            set.sliceSpace = 2
            set.selectionShift = 6
            set.valueTextColor = .white
            set.valueFont = .systemFont(ofSize: 12, weight: .semibold)
            set.entryLabelColor = .white
            
            set.colors = [
                            .systemIndigo, .systemPurple, .systemBlue, .systemTeal, .systemPink,
                            .systemOrange, .systemYellow, .systemGreen, .systemRed, .systemMint
                        ]
            
            let formatter = DefaultValueFormatter { [weak self] value, _, _, _ in
                guard let self else { return "" }
                return self.vm.formatted(amount: value)
            }
            
            let data = PieChartData(dataSet: set)
            data.setValueFormatter(formatter)
            pie.data = data
        } else {
            pie.data = nil
        }
        
        let barEntries: [BarChartDataEntry] = vm.dailyBars.map {
            BarChartDataEntry(x: Double($0.day), y: $0.total)
        }
        
        let barSet = BarChartDataSet(entries: barEntries, label: "")
        barSet.colors = [.systemIndigo]
        barSet.valueTextColor = .white
        barSet.valueFont = .systemFont(ofSize: 10)
        
        let barData = BarChartData(dataSet: barSet)
        barData.setValueFormatter(DefaultValueFormatter { [weak self] v, _, _, _ in
            guard let self else { return "" }
            return v == 0 ? "" : self.vm.formatted(amount: v)
        })
        barData.barWidth = 0.8
        bar.data = barData
        
        bar.xAxis.valueFormatter = DefaultAxisValueFormatter { value, _ in
            let day = Int(value)
            return day % 2 == 0 ? "\(day)" : ""
        }
        
        pie.animate(xAxisDuration: 0.25, yAxisDuration: 0.35)
        bar.animate(yAxisDuration: 0.35)
    }
}

private final class DefaultValueFormatter: ValueFormatter {
    
    private let block: (Double, ChartDataEntry, Int, ViewPortHandler?) -> String
    init(block: @escaping (Double, ChartDataEntry, Int, ViewPortHandler?) -> String) {
        self.block = block
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        block(value, entry, dataSetIndex, viewPortHandler)
    }
}

private final class DefaultAxisValueFormatter: AxisValueFormatter {
    
    private let block: (Double, AxisBase?) -> String
    init(block: @escaping (Double, AxisBase?) -> String) {
        self.block = block
    }
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        block(value, axis)
    }
}

extension StatsViewController: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let entry = entry as? PieChartDataEntry,
              let name = entry.label else { return }

        let amount = vm.formatted(amount: entry.value)

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.white
        ]
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(0.9)
        ]
        let title = NSMutableAttributedString(string: "\(name)\n", attributes: titleAttrs)
        title.append(NSAttributedString(string: amount, attributes: valueAttrs))

        pie.centerAttributedText = title
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        pie.centerText = ""
    }
}
