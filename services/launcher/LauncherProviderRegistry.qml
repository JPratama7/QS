pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "."

// Registry of launcher providers.
// Each provider must implement:
//   - readonly property string providerId
//   - function search(query: string): var (array of plain JS objects with title/subtitle/icon/providerId/data)
//   - function activate(data: var): void
Singleton {
	id: root

	// Registered providers — populated by each provider on Component.onCompleted
	property list<QtObject> providers: []

	function register(provider: QtObject): void {
		root.providers.push(provider);
		root.providersChanged();
	}

	// Run query across all providers, return merged results
	function search(query: string): var {
		const results = [];
		for (const provider of root.providers) {
			const providerResults = provider.search(query);
			for (const r of providerResults) {
				results.push(r);
			}
		}
		return results;
	}

	// Dispatch activation to the provider that owns this result
	// qmllint disable missing-property
	function activate(result: var): void {
		for (const provider of root.providers) {
			if (provider.providerId === result.providerId) {
				provider.activate(result.data);
				return;
			}
		}
	}

	// Instantiate built-in providers — each self-registers via Component.onCompleted
	ApplicationsProvider {
	}
	// qmllint enable missing-property
}
