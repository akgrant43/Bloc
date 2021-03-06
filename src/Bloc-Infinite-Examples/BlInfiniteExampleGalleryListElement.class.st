Class {
	#name : #BlInfiniteExampleGalleryListElement,
	#superclass : #BlInfiniteElement,
	#category : 'Bloc-Infinite-Examples-Core - Gallery'
}

{ #category : #initialization }
BlInfiniteExampleGalleryListElement >> defaultDataSource [
	^ BlInfiniteExampleGalleryDataSource new
]

{ #category : #initialization }
BlInfiniteExampleGalleryListElement >> defaultLayout [
	^ BlInfiniteLinearLayout new
]

{ #category : #'children hooks' }
BlInfiniteExampleGalleryListElement >> onAddedToSceneGraph [
	super onAddedToSceneGraph.

	dataSource requestImages
]
