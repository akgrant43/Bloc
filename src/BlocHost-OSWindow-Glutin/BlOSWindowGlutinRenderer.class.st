Class {
	#name : #BlOSWindowGlutinRenderer,
	#superclass : #BlOSWindowRenderer,
	#instVars : [
		'gl',
		'textureExtent',
		'vertShaderObj',
		'fragShaderObj',
		'progObj',
		'vertexBuff',
		'buffData',
		'texBuff',
		'vloc',
		'tloc',
		'uLoc',
		'texture'
	],
	#pools : [
		'GlutinOpenGLConstants'
	],
	#category : #'BlocHost-OSWindow-Glutin'
}

{ #category : #'instance creation' }
BlOSWindowGlutinRenderer class >> for: aWindowHandle [
	^ self basicNew
		initialize;
		initializeWindowHandle: aWindowHandle;
		yourself
]

{ #category : #'instance creation' }
BlOSWindowGlutinRenderer class >> new [ 
	self error: 'Use #for:'
]

{ #category : #'host space - accessing' }
BlOSWindowGlutinRenderer >> canvasExtent [
	^ window handle framebufferExtent
]

{ #category : #'private - gl' }
BlOSWindowGlutinRenderer >> fragmentShader [
	^ gl shaderVersion >= 410
		ifTrue: [ self fragmentShader410 ]
		ifFalse: [ self fragmentShader330 ]
]

{ #category : #'private - gl' }
BlOSWindowGlutinRenderer >> fragmentShader330 [
	^ '#version 330
	
	precision highp float;
	
	varying vec2 vTex;
	uniform sampler2D sampler0;

	void main(void) {
		gl_FragColor = texture2D(sampler0, vTex);
	}'
]

{ #category : #'private - gl' }
BlOSWindowGlutinRenderer >> fragmentShader410 [
	^ '#version 410
	
	precision highp float;
	
	in vec2 vTex;
	uniform sampler2D sampler0;
	
	out vec4 fragColor;
	void main(void) {
		fragColor = texture(sampler0, vTex);
	}'
]

{ #category : #'host space - drawing' }
BlOSWindowGlutinRenderer >> initializeForBuffer: aBlHostRendererBufferSurface [
	self
		assert: [ self window isNotNil ]
		description: [ 'Window must be set!' ].

	self asCurrentDo: [
		| form pixels |
		textureExtent := aBlHostRendererBufferSurface canvasExtent.
		
		form := Form extent: textureExtent depth: 32.

		pixels := FFIExternalArray externalNewType: FFIUInt32 size: form stride * form height.
		pixels autoRelease.

		aBlHostRendererBufferSurface
			buffer: pixels getHandle;
			stride: form stride;
			extent: textureExtent.
			
		self initializeGL.

		gl viewport_x: 0 y: 0 width: textureExtent x height: textureExtent y ]
]

{ #category : #'host space - drawing' }
BlOSWindowGlutinRenderer >> initializeGL [
	
	gl
		ifNotNil: [ ^ self ].

	gl := self window handle gl.

	vertShaderObj := gl create_vertex_shader.
	fragShaderObj := gl create_fragment_shader.
	gl shader_source: vertShaderObj string: self vertexShader.
	gl shader_source: fragShaderObj string: self fragmentShader.
	gl compile_shader: vertShaderObj.
	gl compile_shader: fragShaderObj.
	
	progObj := gl create_program.
	gl attach_shader: vertShaderObj program: progObj.
	gl attach_shader: fragShaderObj program: progObj.
	
	gl link_program: progObj.
	gl use_program: progObj.
	
	
	vertexBuff := gl create_buffer.
	gl bind_array_buffer: vertexBuff.

	buffData := FFIExternalArray externalNewType: FFIFloat32 size: 8.
	buffData atAll: (1 to: 8) putAll: #(-1 1 -1 -1 1 -1 1 1).
	gl array_buffer_data_static_draw: (buffData getHandle) length: buffData size.
	buffData free.
	
	texBuff := gl create_buffer.
	gl bind_array_buffer: texBuff.

	buffData := FFIExternalArray externalNewType: FFIFloat32 size: 8.
	buffData atAll: (1 to: 8) putAll: #(0 1 0 0 1 0 1 1).
	gl array_buffer_data_static_draw: (buffData getHandle) length: buffData size.
	buffData free.

	vloc := gl get_attribute_location_program: progObj name: 'aVertex'.
	tloc := gl get_attribute_location_program: progObj name: 'aUV'.
	uLoc := gl get_attribute_location_program: progObj name: 'pos'.
	
	texture := gl gen_texture.
]

{ #category : #initialization }
BlOSWindowGlutinRenderer >> initializeWindowHandle: aGlutinWindowHandle [
	self window: aGlutinWindowHandle
]

{ #category : #misc }
BlOSWindowGlutinRenderer >> makeCurrent: aWindow [
	aWindow isValid
		ifFalse: [ ^ false ].
	
	aWindow handle makeCurrent.
	^ true
]

{ #category : #'host space - drawing' }
BlOSWindowGlutinRenderer >> presentBufferSurface: aBlHostRendererBufferSurface areas: aCollectionOfAreas [
	
	self asCurrentDo: [
		| vao |
		
		gl bind_texture_2d: texture.
		gl tex_parameter_i_target: GL_TEXTURE_2D name: GL_TEXTURE_MIN_FILTER param: GL_NEAREST.
		gl tex_parameter_i_target: GL_TEXTURE_2D name: GL_TEXTURE_MAG_FILTER param: GL_NEAREST.
		
		gl
			tex_image_2d_target: GL_TEXTURE_2D
			level: 0
			internalformat: GL_RGBA
			width: textureExtent x
			height: textureExtent y
			border: 0
			format: GL_BGRA
			type: GL_UNSIGNED_BYTE
			pixels: aBlHostRendererBufferSurface buffer
			length: aBlHostRendererBufferSurface stride * textureExtent y * 4.
		
		vao := gl gen_vertex_array.
		gl bind_vertex_array: vao.
		
		gl enable_vertex_attrib_array: vloc.
		gl bind_array_buffer: vertexBuff.
		gl
			vertex_attrib_pointer_index: vloc
			size: 2
			type: GL_FLOAT
			normalized: false
			stride: 0
			offset: 0.
			
		gl enable_vertex_attrib_array: tloc.
		gl bind_array_buffer: texBuff.
		gl
			vertex_attrib_pointer_index: tloc
			size: 2
			type: GL_FLOAT
			normalized: false
			stride: 0
			offset: 0.
			
		gl draw_arrays_mode: GL_TRIANGLE_FAN first: 0 count: 4.	
		
		self swapBuffers ]
]

{ #category : #misc }
BlOSWindowGlutinRenderer >> swapBuffers: aWindow [
	aWindow handle swapBuffers
]

{ #category : #'private - gl' }
BlOSWindowGlutinRenderer >> vertexShader [
	^ gl shaderVersion >= 410
		ifTrue: [ self vertexShader410 ]
		ifFalse: [ self vertexShader330 ]
]

{ #category : #'private - gl' }
BlOSWindowGlutinRenderer >> vertexShader330 [
	^ '#version 330
	
	attribute vec2 aVertex;
	attribute vec2 aUV;
	varying vec2 vTex;
	
	void main(void) {
		gl_Position = vec4(aVertex.x, -aVertex.y, 0.0, 1.0);
		vTex = aUV;
	}'
]

{ #category : #'private - gl' }
BlOSWindowGlutinRenderer >> vertexShader410 [
	^ '#version 410
	
	in vec2 aVertex;
	in vec2 aUV;
	out vec2 vTex;
	
	void main(void) {
		gl_Position = vec4(aVertex.x, -aVertex.y, 0.0, 1.0);
		vTex = aUV;
	}'
]
