pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../types/launcher"
import "."

// Registry of launcher providers.
// Each provider must be a LauncherProvider with:
//   - property string providerId
//   - function search(query: string): var (array of plain JS objects with title/subtitle/icon/providerId/data)
//   - function activate(data: var): void
Singleton {
	id: root

	// Registered providers — populated by each provider on Component.onCompleted
	property list<LauncherProvider> providers: []

	function register(provider: LauncherProvider): void {
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
}
