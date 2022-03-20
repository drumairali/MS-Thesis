function senResp=sensor_resp(GaborFilters,sensorData)
% Sensor Response with Real Sensor Data
numFilters=length(filters);
for i=1:numFilters
    senResp(i)=sum(sum(GaborFilters{i}.*sensorData));
end
senResp=senResp./max(senResp);

