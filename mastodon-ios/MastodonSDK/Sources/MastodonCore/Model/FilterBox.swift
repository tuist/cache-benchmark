//
//  FilterBox.swift
//  MastodonSDK
//
//  Created by Shannon Hughes on 11/22/24.
//

import MastodonSDK
import NaturalLanguage

public extension Mastodon.Entity {
    struct FilterString: Equatable {
        let string: String
        let responsibleFilter: String
    }
    struct FilterBox: Equatable {
        let hideAnyMatch: [FilterContext : [FilterString]]
        let warnAnyMatch: [FilterContext : [FilterString]]
        let hideWholeWordMatch: [FilterContext : [FilterString]]
        let warnWholeWordMatch: [FilterContext : [FilterString]]
        
        public init?(filters: [Mastodon.Entity.FilterInfo]) {
            guard !filters.isEmpty else { return nil }
            
            var _hideAnyMatch = [FilterContext : [FilterString]]()
            var _warnAnyMatch = [FilterContext : [FilterString]]()
            var _hideWholeWordMatch = [FilterContext : [FilterString]]()
            var _warnWholeWordMatch = [FilterContext : [FilterString]]()
            
            for filter in filters {
                for context in filter.filterContexts {
                    let partialWords = filter.matchAll.map { word in
                        return FilterString(string: word, responsibleFilter: filter.name)
                    }
                    let wholeWords = filter.matchWholeWordOnly.map { word in
                        return FilterString(string: word, responsibleFilter: filter.name)
                    }
                    switch filter.filterAction {
                    case .hide:
                        var words = _hideWholeWordMatch[context] ?? []
                        words.append(contentsOf: wholeWords)
                        _hideWholeWordMatch[context] = words
                        
                        words = _hideAnyMatch[context] ?? []
                        words.append(contentsOf: partialWords)
                        _hideAnyMatch[context] = words
                    case .warn, ._other:
                        var words = _warnWholeWordMatch[context] ?? []
                        words.append(contentsOf: wholeWords)
                        _warnWholeWordMatch[context] = words
                        
                        words = _warnAnyMatch[context] ?? []
                        words.append(contentsOf: partialWords)
                        _warnAnyMatch[context] = words
                    }
                }
            }

            warnAnyMatch = _warnAnyMatch
            warnWholeWordMatch = _warnWholeWordMatch
            hideAnyMatch = _hideAnyMatch
            hideWholeWordMatch = _hideWholeWordMatch
        }
        
        public func apply(to status: Mastodon.Entity.Status, in context: FilterContext) -> Mastodon.Entity.FilterResult {
            let status = status.reblog ?? status
            let defaultFilterResult = Mastodon.Entity.FilterResult.notFiltered
            guard let content = status.content?.lowercased() else { return defaultFilterResult }
            return apply(to: content, in: context)
        }
        
        public func apply(to status: MastodonStatus, in context: FilterContext) -> Mastodon.Entity.FilterResult {
            let status = status.reblog ?? status
            let defaultFilterResult = Mastodon.Entity.FilterResult.notFiltered
            guard let content = status.entity.content?.lowercased() else { return defaultFilterResult }
            return apply(to: content, in: context)
        }
            
        public func apply(to content: String?, in context: FilterContext) -> Mastodon.Entity.FilterResult {
            
            let defaultFilterResult = Mastodon.Entity.FilterResult.notFiltered
            
            guard let content else { return defaultFilterResult }
            
            if let warnAny = warnAnyMatch[context] {
                for partialMatchable in warnAny {
                    if content.contains(partialMatchable.string) {
                        return .warn(partialMatchable.responsibleFilter)
                    }
                }
            }
            if let hideAny = hideAnyMatch[context] {
                for partialMatchable in hideAny {
                    if content.contains(partialMatchable.string) {
                        return .hide(partialMatchable.responsibleFilter)
                    }
                }
            }
            
            let warnWholeWord = warnWholeWordMatch[context]
            let hideWholeWord = hideWholeWordMatch[context]
            
            var filterResult = defaultFilterResult
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = content
            
            tokenizer.enumerateTokens(in: content.startIndex..<content.endIndex) { range, _ in
                let word = String(content[range])
                if let hideHit = hideWholeWord?.first(where: { $0.string == word }) {
                    filterResult = .hide(hideHit.responsibleFilter)
                    return false
                } else if let warnHit = warnWholeWord?.first(where: { $0.string == word }) {
                    filterResult = .warn(warnHit.responsibleFilter)
                    return false
                } else {
                    return true
                }
            }
            
            return filterResult
        }
    }
}
