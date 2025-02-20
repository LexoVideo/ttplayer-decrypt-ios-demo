# ttplayer-decrypt-ios-demo

1) get the sdk
edit your podfile, add the dependency
```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/LexoVideo/lexo-dev-specs.git'

pod 'DRMLib'
```

2) implement TTVideoEngineBufferProcessorDelegate

3) use DRMLib to decrypt data
```swift
func prcocess(_ url: String!, intput intputData: Data!) -> TTVideoEngineBufferProcessResult! {
	guard let url, let intputData else {
		fatalError("get an nil url or data from tt sdk")
	}
	
	guard let processor = processorDict[url] else {
		fatalError("get an nil url from tt sdk")
	}
	
	// use DRMProcessor Code in the demo
	return processor.process(url: url, input: intputData)
}
```