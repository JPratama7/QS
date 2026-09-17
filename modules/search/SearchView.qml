pragma ComponentBehavior: Bound

import QtQuick
import "../../config"

// Shared picker view: search field + results list + keyboard navigation.
// Parameterized by the picker service (query/results/selectedIndex/hasResults
// plus selectPrev/selectNext/activateSelected/close) and the row delegate.
Item {
	id: view

	// Picker service — see above for the required surface
	required property var searchService
	// Row delegate component (required properties: modelData, index)
	required property Component resultDelegate
	property string placeholderText: ""
	property int resultsHeight: 400
	property string emptyQueryHint: ""
	property string emptyNoResultsHint: "No results"
	property bool reserveEmptySpace: false

	implicitWidth: column.implicitWidth
	implicitHeight: column.implicitHeight + Theme.paddingNormal * 2

	focus: true

	Keys.onUpPressed: view.searchService.selectPrev()
	Keys.onDownPressed: view.searchService.selectNext()
	Keys.onReturnPressed: view.searchService.activateSelected()
	Keys.onEscapePressed: view.searchService.close()

	function reset(): void {
		searchField.clear();
		searchField.focusInput();
	}

	Rectangle {
		z: -1
		anchors.fill: parent
		color: Theme.surfaceColor
		radius: Theme.radiusNormal
		border.width: 1
		border.color: Qt.alpha(Theme.foregroundColor, 0.1)
	}

	Column {
		id: column

		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			margins: Theme.paddingNormal
		}
		spacing: Theme.spacingNormal

		SearchField {
			id: searchField
			width: parent.width
			searchService: view.searchService
			placeholderText: view.placeholderText
		}

		SearchResultsList {
			width: parent.width
			height: Math.min(implicitHeight, view.resultsHeight)
			searchService: view.searchService
			resultDelegate: view.resultDelegate
			emptyQueryHint: view.emptyQueryHint
			emptyNoResultsHint: view.emptyNoResultsHint
			reserveEmptySpace: view.reserveEmptySpace
		}
	}
}
