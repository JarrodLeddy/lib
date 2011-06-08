
;pro cxml_read, cxmlfile, data, missing_value, error=error
;
;------------------------------------------------------------------------
;Read cyclone data from CXML file
;
;Input:  cxmlfile        Name of CXML file
;Output: data            Output data structure
;                          Returns scalar -999. if problem encountered
;        missing_value   Value of missing data (-999.)
;Keywd:  error           0 if file read properly, non-zero otherwise (see code)
;------------------------------------------------------------------------
;
; Calls object routine CXML
;
; Returns:
;   data = { header:header, data:data[0:nd-1], missing:missing }
;
; Examples of structure elements are:
;   data.header.generatingApplication.model[jm].name
;   data.data[jd].disturbance[ji].fix[jf].cycloneData[jc].minimumPressure.pressure
;
;***** IMPORTANT - READ THIS INFORMATION BEFORE YOU START! **************
; Before using this routine, edit the CXML__define procedure (below) to
; set some reasonable values of:
;   nm     expected maximum number of models in header
;   nd     expected maximum number of data blocks or ensemble members
;   ni     expected maximum number of disturbances
;   nf     expected maximum number of fixes for a disturbance
;   nc     expected maximum number of cycloneData segments for a fix
;************************************************************************
;
; Please send bug reports and suggestions for improvement to Beth Ebert
;   (e.ebert@bom.gov.au)
;
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------



; Init method
; Called when the xmlstruct object is created.

FUNCTION CXML::Init

;Initialize the value of the data counter. It will be
;incremented as elements are added to the array.
self.jd = 0
RETURN, self->IDLffXMLSAX::Init()

END

;---------------------------------------------------------------------------
; Characters method
; Called when parsing character data within an element.
; Adds data to the charBuffer field.

PRO CXML::characters, data

self.charBuffer = self.charBuffer + data

END

;---------------------------------------------------------------------------
; StartElement method
; Called when the parser encounters the start of an element
; If attributes are specified then get their values here
;
; All elements are listed even if no action is taken

PRO CXML::startElement, URI, local, eleName, attrName, attrValue

;Empty the character buffer
self.charBuffer = ''

;Save the element name for getting sub-element information
self.currentEle = eleName

;Number of attributes associated with this element (if any)
nattr=n_elements(attrName)

;Get values of the counters
jm=self.jm   ;models
jd=self.jd   ;data segments
ji=self.ji   ;disturbances
jf=self.jf   ;fixes
jc=self.jc   ;cycloneData segments
jt=self.jt   ;thresholds
js=self.js   ;segments

case eleName of

  'cxml':        ;Root element of CXML file

  'header':             self.parentEle='header'        ;Start of header section

  'product':            self.charBuffer = ''   ;(these statements are probably unnecessary)
  'applicationType':    self.charBuffer = ''
  'model':       ;Start of model sub-section
  'name':               self.charBuffer = ''
  'domain':             self.charBuffer = ''
  'modelResolution':    self.charBuffer = ''
  'dataResolution':     if nattr gt 0 then self.header.generatingApplication.model[jm].dataResolutionUnits=attrValue[0]
  'numMembers':         self.charBuffer = ''
  'perburbationMethod': self.charBuffer = ''
  'productionCenter':   self.charBuffer = ''
  'subCenter':          self.charBuffer = ''
  'moreInfo':           self.charBuffer = ''
  'moreMetadata':       self.charBuffer = ''
  'baseTime':           self.charBuffer = ''
  'creationTime':       self.charBuffer = ''
  'spatialReferenceSystem': self.parentEle='spatialReferenceSystem'

  'data': begin                                        ;Start of cyclone data section
          self.parentEle='data'
          if nattr gt 0 then for ia=0,nattr-1 do begin
            case attrName[ia] of
              'type':    self.data[jd].type=attrValue[ia]
              'member':  self.data[jd].member=attrValue[ia]
              'perturb': self.data[jd].perturb=attrValue[ia]
              'origin':  self.data[jd].origin=attrValue[ia]
              else:
            endcase
            endfor
          end

  'disturbance':   begin
                   self.parentEle='disturbance'
                   self.data[jd].disturbance[ji].ID=attrValue[0]
                   end

  'cycloneName':   self.charBuffer = ''
  'cycloneNumber': self.charBuffer = ''
  'localID':       self.charBuffer = ''
  'basin':         self.charBuffer = ''

  'fix': begin
         self.parentEle='fix'
         if nattr gt 0 then for ia=0,nattr-1 do begin
           case attrName[ia] of
             'hour':   self.data[jd].disturbance[ji].fix[jf].hour=attrValue[ia]
             'source': self.data[jd].disturbance[ji].fix[jf].source=attrValue[ia]
             else:
           endcase
           endfor
         end

  'latitude': begin
         case self.parentEle of
           'fix': begin
              if nattr gt 0 then for ia=0,nattr-1 do begin
                case attrName[ia] of
                  'units':     self.data[jd].disturbance[ji].fix[jf].latitudeUnits=attrValue[ia]
                  'precision': self.data[jd].disturbance[ji].fix[jf].latitudePrecision=attrValue[ia]
                  else:
                endcase
                endfor
              end
           'maximumWind': begin
              if nattr gt 0 then for ia=0,nattr-1 do begin
                case attrName[ia] of
                  'units':     self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.latitudeUnits=attrValue[ia]
                  'precision': self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.latitudePrecision=attrValue[ia]
                 else:
                endcase
                endfor
              end
           else:
         endcase
         end

  'longitude': begin
         case self.parentEle of
           'fix': begin
              if nattr gt 0 then for ia=0,nattr-1 do begin
                case attrName[ia] of
                  'units':     self.data[jd].disturbance[ji].fix[jf].longitudeUnits=attrValue[ia]
                  'precision': self.data[jd].disturbance[ji].fix[jf].longitudePrecision=attrValue[ia]
                  else:
                endcase
                endfor
              end
           'maximumWind': begin
              if nattr gt 0 then for ia=0,nattr-1 do begin
                case attrName[ia] of
                  'units':     self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.longitudeUnits=attrValue[ia]
                  'precision': self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.longitudePrecision=attrValue[ia]
                 else:
                endcase
                endfor
              end
           else:
         endcase
         end

  'accuracy': begin
         case self.parentEle of
           'fix': self.data[jd].disturbance[ji].fix[jf].accuracyUnits=attrValue[0]
           'minimumPressure': self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].minimumPressure.accuracyUnits=attrValue[0]
           'maximumWind':     self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.accuracyUnits=attrValue[0]
           else:
         endcase
         end

  'validTime':        self.charBuffer = ''

  'cycloneData':      begin
                      self.parentEle='cycloneData'
                      if nattr gt 0 then self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].biasCorrected=attrValue[0]
                      end

  'development':      self.charBuffer = ''
  'systemDepth':      self.charBuffer = ''
  'category':         self.charBuffer = ''
  'speed': begin
         case self.parentEle of
           'maximumWind': begin
              if nattr gt 0 then for ia=0,nattr-1 do begin
                case attrName[ia] of
                  'units':     self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.speedUnits=attrValue[ia]
                  'precision': self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.speedPrecision=attrValue[ia]
                 else:
                endcase
                endfor
              end
           else:
         endcase
         end

  'maximumWind':         self.parentEle='maximumWind'
  'minimumPressure':     self.parentEle='minimumPressure'

  'cyclonePhase':        self.parentEle='cyclonePhase'
  'stormRelThkSymmetry': self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].cyclonePhase.stormRelThkSymmetryUnits=attrValue[0]
  'thermalWindUpper':    self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].cyclonePhase.thermalWindUpperUnits=attrValue[0]
  'thermalWindLower':    self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].cyclonePhase.thermalWindLowerUnits=attrValue[0]

  'pressure': begin
           case self.parentEle of
             'minimumPressure': begin
                if nattr gt 0 then for ia=0,nattr-1 do begin
                  case attrName[ia] of
                    'units':     self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].minimumPressure.pressureUnits=attrValue[ia]
                    'precision': self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].minimumPressure.pressurePrecision=attrValue[ia]
                   else:
                  endcase
                  endfor
                end
             else:
           endcase
           end

  'radius': begin
            case self.parentEle of
              'spatialReferenceSystem': self.header.spatialReferenceSystem.radiusUnits=attrValue[0]
              'maximumWind'           : self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.radiusUnits=attrValue[0]
              else:
            endcase
            end
  'sector': self.charBuffer=''
   else:
endcase
self.charBuffer=''  ;reinitialize again for good measure


end

;---------------------------------------------------------------------------
; EndElement method
; Called when the parser encounters the end of an element
; In most cases gets the value of that element

PRO CXML::EndElement, URI, Local, eleName

;print,'endElement - eleName=',eleName

;Get values of the counters
jm=self.jm   ;models
jd=self.jd   ;data segments
ji=self.ji   ;disturbances
jf=self.jf   ;fixes
jc=self.jc   ;cycloneData segments
jt=self.jt   ;thresholds
js=self.js   ;segments

case eleName of

  'cxml':        ;Root element of CXML file

  'header':      ;Start of header section

  'product':            self.header.product=self.charBuffer
  'applicationType':    self.header.generatingApplication.applicationType=self.charBuffer
  'name':               self.header.generatingApplication.model[jm].name=self.charBuffer
  'domain':             self.header.generatingApplication.model[jm].domain=self.charBuffer
  'modelResolution':    self.header.generatingApplication.model[jm].modelResolution=self.charBuffer
  'dataResolution':     self.header.generatingApplication.model[jm].dataResolution=float(self.charBuffer)
  'model':              self.jm = self.jm + 1

  'numMembers':         self.header.generatingApplication.ensemble.numMembers=fix(self.charBuffer)
  'perburbationMethod': self.header.generatingApplication.ensemble.perturbationMethod=self.charBuffer
  'productionCenter':   self.header.productionCenter=self.charBuffer
  'subCenter':          self.header.productionSubCenter=self.charBuffer
  'moreInfo':           self.header.moreInfo=self.charBuffer
  'moreMetadata':       self.header.moreMetadata=self.charBuffer
  'baseTime':           self.header.baseTime=self.charBuffer
  'creationTime':       self.header.creationTime=self.charBuffer

  'data':          begin
                   ;Increment counter for data segments
                   self.jd = self.jd + 1
                   if self.jd gt self.md then self.md=self.jd
                   self.ji = 0
                   end

  'disturbance':   begin
                   ;Increment counter for disturbances
                   self.ji = self.ji + 1
                   if self.ji gt self.mi then self.mi=self.ji
                   self.jf=0
                   end

  'cycloneName':   self.data[jd].disturbance[ji].cycloneName=self.charBuffer
  'cycloneNumber': self.data[jd].disturbance[ji].cycloneNumber=fix(self.charBuffer)
  'localID':       self.data[jd].disturbance[ji].localID=self.charBuffer
  'basin':         self.data[jd].disturbance[ji].basin=self.charBuffer

  'fix':           begin
                   ;Increment counter for fixes
                   self.jf = self.jf + 1
                   if self.jf gt self.mf then self.mf=self.jf
                   self.jc = 0
                   end

  'latitude': begin
         case self.parentEle of
           'fix':         self.data[jd].disturbance[ji].fix[jf].latitude=float(self.charBuffer)
           'maximumWind': self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.latitude=float(self.charBuffer)
           else:
         endcase
         end

  'longitude': begin
         case self.parentEle of
           'fix':         self.data[jd].disturbance[ji].fix[jf].longitude=float(self.charBuffer)
           'maximumWind': self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.longitude=float(self.charBuffer)
           else:
         endcase
         end

  'accuracy': begin
         case self.parentEle of
           'fix': self.data[jd].disturbance[ji].fix[jf].accuracy=float(self.charBuffer)
           'minimumPressure': self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].minimumPressure.accuracy=float(self.charBuffer)
           'maximumWind':     self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.accuracy=float(self.charBuffer)
           else:
         endcase
         end

  'validTime': self.data[jd].disturbance[ji].fix[jf].validTime=self.charBuffer

  'cycloneData':   begin
                   ;Increment counter for cycloneData segments
                   self.jc = self.jc + 1
                   if self.jc gt self.mc then self.mc=self.jc
                   end

  'development':   self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].development=self.charBuffer
  'systemDepth':   self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].systemDepth=self.charBuffer
  'category':      self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].category=fix(self.charBuffer)

  'maximumWind':         self.parentEle='maximumWind'
  'minimumPressure':     self.parentEle='minimumPressure'

  'cyclonePhase':        self.parentEle='cyclonePhase'
  'stormRelThkSymmetry': self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].cyclonePhase.stormRelThkSymmetry=float(self.charBuffer)
  'thermalWindUpper':    self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].cyclonePhase.thermalWindUpper=float(self.charBuffer)
  'thermalWindLower':    self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].cyclonePhase.thermalWindLower=float(self.charBuffer)

  'speed': begin
           case self.parentEle of
             'maximumWind': self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.speed=float(self.charBuffer)
             else:
           endcase
           end

  'pressure': begin
           case self.parentEle of
             'minimumPressure': self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].minimumPressure.pressure=float(self.charBuffer)
             else:
           endcase
           end

  'radius': begin
            case self.parentEle of
              'spatialReferenceSystem': self.header.spatialReferenceSystem.radius=float(self.charBuffer)
              'maximumWind'           : self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.radius=float(self.charBuffer)
              else:
            endcase
            end
  'sector': self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind.sector=self.charBuffer
   else:
endcase

;  print,eleName & help,self.charBuffer

end

;---------------------------------------------------------------------------
; GetData method
; Returns the data stored internally
;   If no data is available, returns missing value   ***NO IT DOESN'T

FUNCTION CXML::GetData

print,'Number of data segments is ',self.jd


if (self.jd eq 0) then $
  return, { header:self.header, data:self.data[0], $
            missing:self.missing } $
else $
  return, { header:self.header, data:self.data[0:self.jd-1], $
            missing:self.missing }

END

;---------------------------------------------------------------------------
; Object class definition method.

PRO CXML__define

missing=-999.

;Rather than using pointers, which could get really messy when dereferencing
;  nested structures, set array sizes big enough so that we can just use
;  subscripts to refer to structure arrays within structures,
;  but not so big that our arrays get too huge.
;Use named structures so that the IDL XML parser will be happy.

;Initial array sizes (maximum number ever??)
nm=1    ;expected maximum number of models in header (10)
nd=53   ;expected maximum number of data blocks or ensemble members (53)
ni=20   ;expected maximum number of disturbances (20)
nf=40   ;expected maximum number of fixes for a disturbance
nc=1    ;expected maximum number of cycloneData segments for a fix (2)
        ;  (this is allow for multiple eyes in a storm)
;NOT USED AT THE MOMENT BUT COULD BE USED LATER...
nt=4    ;expected maximum number of thresholds for wind, sea, fixed radii (4)
ns=9    ;expected maximum number of radius sectors (9)


;Define a structure for header information

void = {model, name:'', domain:'', modelResolution:'', dataResolution:0., $
        dataResolutionUnits:'', productionStatus:'' }

void = {ensemble, numMembers:0, perturbationMethod:'' }

void = {generatingApplication, applicationType:'', $
        model:replicate({model},nm), ensemble:{ensemble} }

void = {spatialReferenceSystem, name:'', radius:0., radiusUnits:'' }

void = {header, $
        product:'', generatingApplication:{generatingApplication}, $
        productionCenter:'', productionSubCenter:'', $
        moreInfo:'', moreMetadata:'', baseTime:'', creationTime:'', $
        spatialReferenceSystem:{spatialReferenceSystem} }


;Define a structure for CXML data, from the inside out

;Nesting level = 5  self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].cyclonePhase
void = {cyclonePhase, stormRelThkSymmetry:0., stormRelThkSymmetryUnits:'', $
        thermalWindUpper:0., thermalWindUpperUnits:'', $
        thermalWindLower:0., thermalWindLowerUnits:'' }

;Nesting level = 5  self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].minimumPressure
void = {minimumPressure, pressure:0., pressureUnits:'', pressurePrecision:0., $
        accuracy:0., accuracyUnits:'' }

;Nesting level = 5  self.data[jd].disturbance[ji].fix[jf].cycloneData[jc].maximumWind
void = {maximumWind, speed:0., speedUnits:'', speedPrecision:0., $
        accuracy:0., accuracyUnits:'', $
        latitude:0., latitudeUnits:'', latitudePrecision:0., $
        longitude:0., longitudeUnits:'', longitudePrecision:0., $
        radius:0., radiusUnits:'', sector:'' }

;Nesting level = 4  self.data[jd].disturbance[ji].fix[jf].cycloneData[jc]
void = {cycloneData, biasCorrected:'', development:'', systemDepth:'', category:0, $
        cyclonePhase:{cyclonePhase}, minimumPressure:{minimumPressure}, $
        maximumWind:{maximumWind}, comments:''}

;Nesting level = 3  self.data[jd].disturbance[ji].fix[jf]
void = {fix, hour:0, source:'', validTime:'', $
        latitude:0., latitudeUnits:'', latitudePrecision:0., $
        longitude:0., longitudeUnits:'', longitudePrecision:0., $
        accuracy:0., accuracyUnits:'', $
        cycloneData:replicate({cycloneData},nc) }

;Nesting level = 2  self.data[jd].disturbance[ji]
void = {disturbance, ID:'', cycloneName:'', cycloneNumber:0, localID:'', $
        basin:'', fix:replicate({fix},nf) }

;Nesting level = 1  self.data[jd]
void = {data, type:'', member:0, perturb:'', origin:'', $
        disturbance:replicate({disturbance},ni) }


;Define the class data structure

void = { CXML, $
   INHERITS IDLffXMLSAX, $
   currentEle:'', $
   CharBuffer:'', $
   parentEle:'', $
   jm:0, jd:0, ji:0, jf:0, jc:0, jt:0, js:0, $   ;counters
   mm:0, md:0, mi:0, mf:0, mc:0, mt:0, ms:0, $   ;max values of counters
   header:{header}, data:replicate({data},nd), missing:missing }

end

;------------------------------------------------------------------------

pro cxml_read, cxmlfile, data, missing_value, $
  error=error

;------------------------------------------------------------------------
;Read cyclone data from CXML file
;
;Input:  cxmlfile        name of CXML file
;Output: data            data structure (see CXML::GetData method and
;                          CXML__define procedure)
;                          Returns scalar missing value if problem encountered
;        missing_value   value of missing data (ex: -999.)
;Keywd:  error           0 if file read properly, non-zero otherwise (see code)
;
;Called by:
;------------------------------------------------------------------------

error=0
missing_value=-999.

;Establish error handler
CATCH, Error_status
if Error_status ne 0 then begin
  print, 'cxml_read - ', !ERROR_STATE.MSG
  CATCH, /CANCEL
  goto, bad_data
  endif


;Check that file exists
if (file_info(cxmlfile)).exists eq 0 then begin
  print,'cxml_read - file does not exist - '+cxmlfile+' - quit!'
  error=1
  data=missing_value
  return
  endif


;Use object code to read the cyclone data from the CXML file
; Returns
;
;   d = { header:header, data:data[0:nd-1], missing:missing }
;
; where nd is the number of data segments

a=obj_new('CXML')
a->ParseFile,cxmlfile
d=a->getData()
obj_destroy,a

if (d.data[0].type) eq '' then begin
  print,'cxml_read - no cyclone data could be read - quit!'
  error=2
  data=missing_value
  return
  endif


;Rationalize structure - get rid of empty elements as much as possible
;;;data = rationalize_structure(d) ;NOT WORKING YET
data=temporary(d)

done: print,'cxml_read - read cyclone data from '+cxmlfile
return

bad_data:
print,'cxml_read - trouble reading data from file - '+cxmlfile+' - quit!'
error=3
data=missing_value

end
