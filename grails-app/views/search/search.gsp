<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
<meta name="layout" content="main"/>
<title>Apolo Music</title>
</head>
<body>
  <div class="body">
  		<div class="row centered" style="margin-bottom: 10px;">
  			<a target="_blank" href="https://www.surveymonkey.com/s/R3PXCYR">Help us improve the system by completing this survey.</a>
  		</div> 
  		<div class="row">
			<div class="col-lg-3"></div>
				<div class="col-lg-6">
					<g:form name="search-form" method="get" role="form" controller="search" action="index">
						<div class="form-group">
							<div class="input-group">
			                    <input tabindex="1" required value="${params.keyword}" name="keyword" autocomplete="off" id="search" type="text" class="form-control input-lg" placeholder="What are you looking for?">
			                    <span class="input-group-addon"><a id="voice-search-btn" href="javascript:void(0)"><i class="fa fa-microphone"></i></a></span>
			                    <span class="input-group-addon"><a id="voice-record-btn" href="javascript:void(0)"><i class="fa fa-headphones"></i></a></span>
	                  		</div>
	                  	</div>	
                  	
                  		<div class="form-group">
	                  		<div class="input-group" style="margin: auto">
			                    <button class="btn btn-block btn-default">Search with Apolo music</button>
	                  		</div>
                  		</div>
					</g:form>
				</div>
				<div class="col-lg-3"></div>
			</div>
		</div>	
		
		<g:if test="${isSearching == true}">
			<div class="row">
				<div class="col-lg-9">
					<g:if test="${!spellingCorrectedString.equals("")}">
						<h4>
							Did you mean: 
							<g:link controller="search" params="[keyword: spellingCorrectedString]">
		     					${spellingCorrectedString}
							</g:link>
						</h4>
					</g:if>
				</div>
				
				<div class="col-lg-3"></div>
			</div>
			
			<div class="row">
				<div class="col-lg-9">
					<div class="nav-tabs-custom">
		                <ul class="nav nav-tabs">
							<li class="${!searchingForArtist ? 'active':''}"><a href="#tab-song" data-toggle="tab" aria-expanded="false">Songs</a></li>
		                  	<li class="${searchingForArtist ? 'active':''}"><a href="#tab-artist" data-toggle="tab" aria-expanded="false">Artists</a></li>
		                 	<li><a href="#tab-release" data-toggle="tab" aria-expanded="true">Releases</a></li>
		                </ul>
		                
		                
		                <div class="tab-content">
		                  	<div class="tab-pane ${!searchingForArtist ? 'active':''}" id="tab-song">
		                  		<g:each in="${songs}" var="song" status="songCounter">
		                  			<g:if test="${songCounter==0}">
		                  				<g:render template="/template/first-song" model="[song: song]"/>
		                  			</g:if>
		                  			<g:else>
		                  				<g:render template="/template/song-result" model="[song: song]"/>
									</g:else>
		                  		</g:each>
		                  			
		                </div><!-- /.tab-pane -->
		                
		                  <div class="tab-pane ${searchingForArtist ? 'active':''}" id="tab-artist">
		                    	<g:each in="${artists}" var="artist" status="artistCounter">
		                  			<g:if test="${artistCounter==0}">
		                  				<g:render template="/template/first-artist" model="[artist: artist, firstArtistSongs: firstArtistSongs]"/>
		                  			</g:if>
		                  			<g:else>
		                  				<g:render template="/template/artist-result" model="[artist: artist]"/>
									</g:else>
		                  		</g:each>
		                  </div><!-- /.tab-pane -->
		                  
		                  <div class="tab-pane" id="tab-release">
		                    	<g:each in="${releases}" var="release" status="releaseCounter">
		                  			<% 
								   		ArrayList<String> releaseSongsTmp = release.getSplittedFields(release.releaseSongs);
								   		ArrayList<String> releaseSongIDsTmp = release.getSplittedFields(release.releaseSongIDs);
									    ArrayList<String> releaseSongs = new ArrayList<String>();
									    ArrayList<String> releaseSongIDs = new ArrayList<String>();
										   
										Set<String> releaseSongsSet = new HashSet<String>();
										for(int i = 0 ; i < releaseSongsTmp.size(); i++) {
											String songName = releaseSongsTmp.get(i);
											if (!releaseSongsSet.contains(songName)) {
												releaseSongsSet.add(songName);
												releaseSongs.add(releaseSongsTmp.get(i));
												releaseSongIDs.add(releaseSongIDsTmp.get(i));
											}
										}   
										
									 %>
		                  			<g:if test="${releaseCounter==0}">
		                  				<g:render template="/template/first-release" model="[release: release, releaseSongs: releaseSongs, releaseSongIDs : releaseSongIDs]"/>
		                  			</g:if>
		                  			<g:else>
		                  				<g:render template="/template/release-result" model="[release: release, releaseSongs: releaseSongs, releaseSongIDs : releaseSongIDs]"/>
									</g:else>
		                  		</g:each>
		                  </div><!-- /.tab-pane -->
				     </div><!-- /.tab-content -->
				  </div>
				</div>
					
				<!-- RECOMMENDATION -->
				<div class="col-lg-3">
						<div class="box box-default">
			                <div class="box-header with-border">
			                 	<i class="fa fa-thumbs-up	"></i>
			                  	<h3 class="box-title">You might be interested</h3>
			                </div><!-- /.box-header -->
			                
			                <g:if test="${artists.size() > 0}">
				                <div class="box-body artist-recomendation-wrapper" artist-id="${artists.get(0).artistID}">
					                	<div class="clearfix"></div>
					                 	<div class="overlay centered" style="height: 30px; position: relative;"><i class="fa fa-circle-o-notch fa-spin"></i></div>
				                </div><!-- /.box-body -->
				                <script type="text/javascript">
					                function initRecommendation() {
					        			var artistID = $('.artist-recomendation-wrapper').attr("artist-id")
					        			$.ajax({
					        				url : "search/getRecommendationArtist?artistID=" + artistID,
					        				success: function(data) {
					        					$('.artist-recomendation-wrapper').html(data);
					        					initModalEntity();
					        				}
					        			});
					        		}
					                initRecommendation();
				                </script>
			                </g:if>
	             		</div>
	                </div>
			</div>
			
			<!-- MODEL TEMPLATE -->
			<div id="entity-modal" class="modal" style="display: none">
            	<div class="modal-dialog modal-lg">
                	<div class="modal-content">
                  		<div class="modal-header">
                    		<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                    		<h4 class="modal-title">Modal Default</h4>
                  		</div>
                  		
                  		<div class="modal-body">
                    		<p>One fine body…</p>
                  		</div>
                  	
                </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
            </div>
 	 </g:if>
 	 
 	  <!-- AUDIO RECORDING MODEL -->
       <div id="audio-modal" class="modal" style="display: none">
       	<div class="modal-dialog modal-lg">
           	<div class="modal-content">
             		<div class="modal-header">
               		<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
               		<h4 class="modal-title">Recording...</h4>
             		</div>
             		
             		<div class="modal-body">
            				<div class="centered" style="font-size: 30px">
            					<i class="fa fa-fw fa-headphones"></i>
            				</div>
               			<div class="progress" style="margin-top: 10px; margin-bottom: 10px">
		                    <div class="progress-bar progress-bar-primary progress-bar-striped" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width: 0%">
		                      	<span style="position: static"class="sr-only">0</span>
		                    </div>
		                  </div>
             		</div>
           </div><!-- /.modal-content -->
         </div><!-- /.modal-dialog -->
       </div>
 	 
	 <script src="${resource(dir: 'js', file: 'plugins/recording/mp3recorder.js')}" type="text/javascript"></script>
	 
 	 <script type="text/javascript">
	   //Voive recognition
	  	var recognition = new webkitSpeechRecognition();
	  	recognition.onresult = function(event) { 
	    	  if (event.results.length > 0) {
	    		 var string = event.results[0][0].transcript;
	    		 $('#search').val(string);
	    		 $('#search-form').submit();
	    	  } 
	    	}

    	$('#search-form').on("submit", function(){
        	$(this).find("button").prop("disabled", true);
        });
			
	  	$(document).ready(function(){

	  		$('#search').focus();
		  	
			$('ul.typeahead.dropdown-menu').css('width', $('#search').css('width'));
			
			$('#voice-search-btn').click(function(){
				recognition.start();
			});

			initAutocomplete();

			initModalEntity();

			initRecording();

			initLoadAllArtistSongs();
		});

		function initAutocomplete() {
			$('#search').keyup(function(e){
				var code = e.keyCode || e.which;
				//only accept some code: http://www.cambiaresearch.com/articles/15/javascript-char-codes-key-codes
				if ((code >= 48 && code <= 90) || (code >= 186 && code <= 222)) {
					delay(function(){
						getSuggestion();
				    }, 500 );
				}
			});
		}

		function getSuggestion() {
			var query = $('#search').val();
			$.ajax({
				type: "post",
				url: "search/getSuggestion",
				data: {keyword : query},
				success: function(data) {
					$("#search").typeahead("destroy");
					$("#search").typeahead({ source: data.suggestions });
					$("#search").typeahead('lookup');
					initAutocomplete();
				}
			});
		}

		function initModalEntity() {
			$('#entity-modal').modal({show : false})
			$('#entity-modal').on('hidden.bs.modal', function (e) {
				$('#entity-modal .modal-body').html("");
			});
			$("a.load-document-id").unbind('click').click(function(e){
				var entityID = $(this).attr("entity-id")
				$.ajax({
					url : "search/getEntity?entityID=" +entityID,
					dataType: "json",
					beforeSend: function() {
						$('#entity-modal .modal-body').html('<div class="overlay centered"><i class="fa fa-circle-o-notch fa-spin"></i></div>');
						$('#entity-modal').modal('hide');
						$('#entity-modal').modal('show');
						$('#entity-modal .modal-title').html("Loading...");
					},
					success: function(data) {
						$('#entity-modal .modal-body').html(data.data)
						$('#entity-modal .modal-title').html(data.entityName);
						initLoadAllArtistSongs();
					}
				});
			});
		}
    </script>
</body>
</html>