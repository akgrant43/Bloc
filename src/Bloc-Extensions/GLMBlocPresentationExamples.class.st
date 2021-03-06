Class {
	#name : #GLMBlocPresentationExamples,
	#superclass : #Object,
	#category : #'Bloc-Extensions-Examples'
}

{ #category : #'as yet unclassified' }
GLMBlocPresentationExamples >> populatingTheSelectionPortDirectly [
	<gtExample>
	| composite |
	composite := GLMCompositePresentation new.
	composite bloc
		element: [ :blocPresentation :number |
			| root labelText label |
			root := BlElement new constraintsDo: [:c | c horizontal fitContent. c vertical fitContent].
			root layout: (BlGridLayout new columnCount: 6; cellSpacing: 10).
			(1 to: number) do: [ :index |
				labelText := index asString asRopedText.
				label := BlTextElement new.
				label text: labelText.
				root addChild: label ].
			root
				when: BlClickEvent do: [:event | blocPresentation selection: event target text ]].
	^ composite startOn: 42
]

{ #category : #'as yet unclassified' }
GLMBlocPresentationExamples >> populatingTheSelectionPortViaEvent [
	<gtExample>
	| composite |
	composite := GLMCompositePresentation new.
	composite bloc
		element: [ :blocPresentation :number |
			| root labelText label |
			root := BlElement new constraintsDo: [:c | c horizontal fitContent. c vertical fitContent].
			root layout: (BlGridLayout new columnCount: 6; cellSpacing: 10).
			(1 to: number) do: [ :index |
				labelText := index asString asRopedText.
				label := BlTextElement new.
				label text: labelText.
				root addChild: label ].
			root
				when: BlClickEvent do: [:event | root fireEvent: (GLMBlocObjectToSelect new toSelect: event target text) ]].
	^ composite startOn: 42
]
