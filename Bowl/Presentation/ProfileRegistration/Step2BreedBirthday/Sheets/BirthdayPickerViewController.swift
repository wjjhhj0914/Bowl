//
//  BirthdayPickerViewController.swift
//  Bowl
//
//  생일 bottom sheet: a title/subtitle, 년도·월·일 column headers, a
//  three-wheel picker (year / month / day), and a "확인" button. The day
//  wheel adjusts to the selected month/year. Reports the chosen date back.
//

import UIKit
import SnapKit

final class BirthdayPickerViewController: BottomSheetViewController {

    /// Called with the chosen birthday.
    var onSelect: ((Date) -> Void)?

    private let calendar = Calendar.current
    private let years: [Int]
    private let months = Array(1...12)
    private var days: [Int] = Array(1...31)
    private let initialDate: Date

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "생일을 선택해 주세요"
        label.font = AppFont.sheetTitle
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "생년월일 입력 후 묘령이 자동으로 계산됩니다"
        label.font = AppFont.sheetSubtitle
        label.textColor = AppColor.textTertiary
        label.textAlignment = .center
        return label
    }()

    private lazy var headerStack: UIStackView = {
        let labels = ["년도", "월", "일"].map { title -> UILabel in
            let label = UILabel()
            label.text = title
            label.font = AppFont.pickerHeader
            label.textColor = AppColor.textTertiary
            label.textAlignment = .center
            return label
        }
        let stack = UIStackView(arrangedSubviews: labels)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.divider
        return view
    }()

    private let pickerView = UIPickerView()
    private let confirmButton = PrimaryButton(title: "확인")

    // MARK: - Init

    init(initialDate: Date) {
        self.initialDate = initialDate
        let currentYear = Calendar.current.component(.year, from: Date())
        years = Array(2005...currentYear)
        super.init(sheetHeight: 470)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        setupLayout()
        selectInitialDate(initialDate)
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Rows only exist once displayed; paint the centered values now.
        repaintSelection()
    }

    private func setupLayout() {
        [titleLabel, subtitleLabel, headerStack, divider, pickerView, confirmButton].forEach { sheetView.addSubview($0) }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(sheetView.snp.top).offset(24)
            make.centerX.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        headerStack.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(18)
            make.leading.equalTo(sheetView).offset(24)
            make.trailing.equalTo(sheetView).offset(-24)
        }

        divider.snp.makeConstraints { make in
            make.top.equalTo(headerStack.snp.bottom).offset(6)
            make.leading.trailing.equalTo(sheetView)
            make.height.equalTo(1)
        }

        confirmButton.snp.makeConstraints { make in
            make.leading.equalTo(sheetView).offset(24)
            make.trailing.equalTo(sheetView).offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            make.height.equalTo(52)
        }

        pickerView.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom)
            make.leading.trailing.equalTo(sheetView)
            make.bottom.equalTo(confirmButton.snp.top).offset(-8)
        }
    }

    // MARK: - Selection

    private func selectInitialDate(_ date: Date) {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let year = comps.year ?? years.last!
        let month = comps.month ?? 1
        let day = comps.day ?? 1

        // Build the day range up front so all three wheels select cleanly.
        days = Array(1...numberOfDays(year: year, month: month))
        pickerView.reloadComponent(2)

        if let yIndex = years.firstIndex(of: year) {
            pickerView.selectRow(yIndex, inComponent: 0, animated: false)
        }
        pickerView.selectRow(month - 1, inComponent: 1, animated: false)
        pickerView.selectRow(min(day, days.count) - 1, inComponent: 2, animated: false)
    }

    private var selectedYear: Int { years[pickerView.selectedRow(inComponent: 0)] }
    private var selectedMonth: Int { months[pickerView.selectedRow(inComponent: 1)] }
    private var selectedDay: Int { days[pickerView.selectedRow(inComponent: 2)] }

    /// Rebuilds the day wheel when the month/year changes the day count.
    private func rebuildDaysIfNeeded() {
        let count = numberOfDays(year: selectedYear, month: selectedMonth)
        guard count != days.count else { return }
        let currentDay = min(pickerView.selectedRow(inComponent: 2) + 1, count)
        days = Array(1...count)
        pickerView.reloadComponent(2)
        pickerView.selectRow(currentDay - 1, inComponent: 2, animated: false)
    }

    private func numberOfDays(year: Int, month: Int) -> Int {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        guard let date = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: date) else { return 31 }
        return range.count
    }

    private func selectedDate() -> Date {
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = selectedMonth
        comps.day = selectedDay
        return calendar.date(from: comps) ?? Date()
    }

    // MARK: - Row styling

    private func value(component: Int, row: Int) -> Int {
        switch component {
        case 0: return years[row]
        case 1: return months[row]
        default: return days[row]
        }
    }

    private func styleRow(_ label: UILabel, value: Int, isSelected: Bool) {
        label.text = "\(value)"
        label.textAlignment = .center
        label.font = isSelected ? AppFont.pickerValue : AppFont.listRow
        label.textColor = isSelected ? AppColor.primary : AppColor.textTertiary
    }

    /// Repaints every component so that only the centered row (in year, month
    /// AND day) is blue and all others revert to gray. Reloading forces
    /// `viewForRow` to re-run for all visible rows; re-selecting immediately
    /// afterwards guarantees the wheels never jump, regardless of whether the
    /// reload resets the selection.
    private func repaintSelection() {
        let selections = (0..<pickerView.numberOfComponents).map {
            pickerView.selectedRow(inComponent: $0)
        }
        pickerView.reloadAllComponents()
        for (component, row) in selections.enumerated() {
            pickerView.selectRow(row, inComponent: component, animated: false)
        }
    }

    @objc private func didTapConfirm() {
        onSelect?(selectedDate())
        dismiss(animated: true)
    }
}

// MARK: - UIPickerViewDataSource

extension BirthdayPickerViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 3 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return years.count
        case 1: return months.count
        default: return days.count
        }
    }
}

// MARK: - UIPickerViewDelegate

extension BirthdayPickerViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        styleRow(
            label,
            value: value(component: component, row: row),
            isSelected: row == pickerView.selectedRow(inComponent: component)
        )
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 || component == 1 {
            rebuildDaysIfNeeded()
        }
        repaintSelection()
    }
}
