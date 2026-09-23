pragma ComponentBehavior: Bound

import QtQuick
import "../../config"

// Shared results list for the picker overlays. The row delegate is provided by
// each picker (required properties: modelData, index); empty-state behavior is
// configurable — the launcher reserves space and shows a start-typing hint,
// cliphist/emoji show a no-results hint only after typing.
Item {
	id: root

	// Picker service — must expose query/results/selectedIndex/hasResults
	required property var searchService
	// Row delegate component (required properties: modelData, index)
	required property Component resultDelegate
	// Hint shown when the query is empty ("" = never shown)
	property string emptyQueryHint: ""
	// Hint shown when a query has no matches
	property string emptyNoResultsHint: "No results"
	// Reserve layout space for the hint when there are no results (launcher)
	property bool reserveEmptySpace: false

	// Reserve space for the empty hint when there are no results, so the
	// message has room to render instead of collapsing to zero height.
	implicitHeight: root.searchService.hasResults
		? resultsView.contentHeight
		: (root.reserveEmptySpace ? emptyHintColumn.implicitHeight + Theme.paddingNormal * 2 : 100)

	ListView {
		id: resultsView

		anchors.fill: parent
		visible: root.searchService.hasResults
		model: root.searchService.results
		delegate: root.resultDelegate
		spacing: Theme.spacingSmall
		clip: true
		highlightFollowsCurrentItem: true
		highlightMoveDuration: Theme.listHighlightDuration
		highlightResizeDuration: Theme.listHighlightDuration
		currentIndex: root.searchService.selectedIndex

		highlight: Rectangle {
			color: Theme.accentSoft
			radius: Theme.radiusInner
		}
	}

	// Empty state — shown on open (no query yet) and/or on a failed search,
	// depending on the picker's hint configuration.
	Column {
		id: emptyHintColumn

		anchors.centerIn: parent
		spacing: 2

		Text {
			text: root.emptyQueryHint
			color: Theme.mutedColor
			font.pixelSize: Theme.fontSizeNormal
			font.family: Theme.fontFamily
			visible: !root.searchService.hasResults && root.searchService.query === "" && root.emptyQueryHint !== ""
		}
		Text {
			text: root.emptyNoResultsHint
			color: Theme.mutedColor
			font.pixelSize: Theme.fontSizeNormal
			font.family: Theme.fontFamily
			visible: !root.searchService.hasResults && root.searchService.query !== ""
		}
	}
}
