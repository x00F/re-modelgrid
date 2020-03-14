require 'normalize.css'
require 're-slide/dist/re-slide.css'
require 're-lui/dist/lui-mid.css'
window.log = console.log.bind(console)
{createElement,Component} = require 'react'
global.Component = Component
global.h = createElement
{render} = require 'react-dom'
ModelGrid = require './components/ModelGrid.coffee'

Slide = require 're-slide'
{Style,Input,MenuTab,Menu,Bar,StyleContext} = require 're-lui'

adler = require 'adler-32'
demo_models = require './demo-models.coffee'

window.adler = adler

class Demo extends Component
	constructor: (props)->
		super(props)
		@state =
			primary:'#2c2e30'
			primary_inv: '#fff'
			secondary: '#fff'
			secondary_inv: '#386277'
			primary2:'#fff'
			secondary2:'#fff'
			primary2_inv:'#323233'
			secondary2_inv:'#5498bb'

	
	onSetStyle: (primary,secondary)=>
		@setState
			background: primary.inv[0]
			color: primary.color[0]
	onSetStyle2: (primary,secondary)=>
		@setState
			background2: primary.inv[0]
			color2: primary.color[0]
	
	componentDidMount: =>
		window.addEventListener 'resize',()=>
			@forceUpdate()


	render: ->
		h Style,
			primary: @state.primary
			secondary: @state.secondary
			secondary_inv: @state.secondary_inv
			primary_inv: @state.primary_inv
			onSetStyle: @onSetStyle
			h Slide,
				vert:yes
				beta: 100
				style:
					height: '100%'
					width: '100%'
				slide: no
				# h Slide,
				# 	beta: 30
				# 	h ModelGridExample,
				# 		key: 1
				# 		renderHoverBox: @renderHoverBox
				# 		setHoverBox: @setHoverBox
				# h Slide,
				# 	beta: 70
				h Style,
					primary: @state.primary2
					primary_inv: @state.primary2_inv
					secondary: @state.secondary2
					secondary_inv: @state.secondary2_inv
					darken_factor: .88
					onSetStyle: @onSetStyle2
					h ModelGridExample,
						key: 2
						renderHoverBox: @renderHoverBox
						setHoverBox: @setHoverBox




getStateConfig = (model)->
	model_cfg = localStorage.getItem(model.name)
	if model_cfg
		# log 'load config for',model.name,localStorage.getItem(model.name+'-sum')
		return JSON.parse(model_cfg)




setStateConfig = (model,cfg)->
	cfg = JSON.stringify(cfg)
	cfg_sum = (adler.str(cfg,"overkill") >>> 0).toString(32)
	prev_sum = localStorage.getItem(model.name+'-sum')
	if prev_sum != cfg_sum
		# log 'save config for',model.name,cfg_sum
		localStorage.setItem(model.name+'-sum',cfg_sum)
		localStorage.setItem(model.name,cfg)




PUBLIC_QUERIES = JSON.parse(localStorage.getItem('public-queries')||'[]')
PRIVATE_QUERIES = JSON.parse(localStorage.getItem('private-queries')||'[]')
SCHEMA_STATES = {}

class ModelGridExample extends Component
	constructor: (props)->
		super(props)
		@state =
			selected_model_index: 0
			schema_data_sync_id: Date.now()

	selectModelIndex: (i)=>
		@setState
			selected_model_index: i
			# schema_data_sync_id: Date.now()


	mapMenuModels: (model,i)=>
		h Input,
			type: 'button'
			key: i
			# btn_type: 'primary'
			label: String(i)
			onClick: @selectModelIndex.bind(@,i)
			select: i == @state.selected_model_index




				
	render: ->

		schema_state = getStateConfig(demo_models.models[@state.selected_model_index])
		

		h Slide,
			vert: no
			h Style,
				primary: '#000'
				primary_inv: '#fde400'
				h Slide,
					style:
						background: '#fde400'
						color: '#000'
						overflow: 'visible'
					dim: 30
					h 'div',
						className: 'flex-down'
					# h Menu,
					# 	hover_reveal_enabled: yes
					# 	big: no
					# 	vert: yes
					# 	split_x: 1
					# 	split_y: 1
						h Bar,
							vert: yes
							demo_models.models.map @mapMenuModels
							h Input,
								key: 'sync'
								onClick: ()=>
									@setState
										schema_data_sync_id: Date.now()
								i: 'refresh'
								type: 'button'

			h Slide,
				beta: 100
				style:
					background: @context.primary.inv[0]
					color: @context.primary.color[0]
				h ModelGrid,
					schema: demo_models.models[@state.selected_model_index]
					schema_data_sync_id: @state.schema_data_sync_id
					data_item_id: @state.data_item_id
					onSchemaStateUpdated: setStateConfig.bind(null,demo_models.models[@state.selected_model_index])
					setHoverBox: @props.setHoverBox
					renderHoverBox: @props.renderHoverBox


				
					onError: (err)->
						console.error err
						alert('ERROR '+err.message)

					selectDataItem: (doc_id)=>
						@setState
							data_item_id: doc_id
					
					filter: (schema)=>
						@setState
							test_filter:schema.name



				


					runQuery: (query)=>
						new Promise (resolve,reject)=>
							setTimeout ()=>
								if query.input_value == '{}'
									reject new Error 'test error for input_value == {} (type something in the search field)'
								else
									resolve(demo_models.data[@state.selected_model_index].slice(query.skip,query.skip+query.limit))
								
							,500


					getSchemaPrivateQueries: (schema_name)->
						return new Promise (resolve,reject)->
							setTimeout ()=>
								resolve(PRIVATE_QUERIES[schema_name])
							,500



					getSchemaPublicQueries: (schema_name)->
						return new Promise (resolve,reject)->
							setTimeout ()=>
								resolve(PUBLIC_QUERIES[schema_name])
							,500



					getSchemaState: (schema_name)->
						return new Promise (resolve,reject)->
							setTimeout ()=>
								resolve(SCHEMA_STATES[schema_name])
							,500



					saveQuery: (schema_name,query_item)->
						if query_item.is_public
							PUBLIC_QUERIES.push query_item
							localStorage.setItem('public-queries',JSON.stringify(PUBLIC_QUERIES))
						else
							PRIVATE_QUERIES.push query_item
							localStorage.setItem('private-queries',JSON.stringify(PRIVATE_QUERIES))
						
						return new Promise (resolve,reject)->
							setTimeout ()=>
								resolve(true)
							,1000



					saveSchemaState: (schema_name,schema_state)=>
						SCHEMA_STATES[schema_name] = schema_state
						localStorage.setItem('schema-state-'+schema_name,JSON.stringify(SCHEMA_STATES[schema_name]))



					createDataItem: (doc)=>
						return new Promise (resolve,reject)=>
							setTimeout ()=>
								reject(new Error 'test error - failed to create doc')
							,1000



					runDataItemMethod: (schema,data_item,method)=>
						return new Promise (resolve,reject)=>
							setTimeout ()=>
								resolve
									data_item: data_item
									method_res:
										test_response: 200
							,1000


					updateDataItem: (doc_id,updates)=>
						return new Promise (resolve,reject)=>
							setTimeout ()=>
								for d,i in demo_models.data[@state.selected_model_index]
									if d._id == doc_id
										Object.assign d,{"TEST":"this is a fake update"},updates
										return resolve(d)
								reject(new Error 'not found')
							,500


					# deleteDataItem: (doc_id)=>
					# 	return new Promise (resolve,reject)=>
					# 		setTimeout ()=>
					# 			for d,i in demo_models.data[@state.selected_model_index]
					# 				if d._id == doc_id
					# 					demo_models.data[@state.selected_model_index].splice(i,1)
					# 					return resolve(doc_id)
					# 			reject(new Error 'not found')
					# 		,500


					getDataItem: (doc_id)=>
						# log doc_id
						return new Promise (resolve,reject)=>
							setTimeout ()=>
								for d,i in demo_models.data[@state.selected_model_index]
									if d._id == doc_id
										gd = Object.assign {},d
										gd.test_1234 = {abc:{gg:"12345123"}}
										return resolve(gd)
								reject(new Error 'not found')
							,500


ModelGridExample.contextType = StyleContext

window.demo = render(h(Demo),window.demo)