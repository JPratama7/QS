pragma ComponentBehavior: Bound

import QtQuick

// Base type for launcher providers.
// Providers must:
//   - Set providerId to a unique string identifier
//   - Implement search(query: string): var returning results
//   - Implement activate(data: var): void to handle selection
QtObject {
	id: provider

	// Unique identifier for this provider type
	required property string providerId

	// Search for items matching the query.
	// Return array of plain JS objects with: { title, subtitle, icon, providerId, data }
	function search(query: string): var {
		return [];
	}

	// Activate the result associated with the given data.
	function activate(data: var): void {
		// Subclasses override this
	}
}
