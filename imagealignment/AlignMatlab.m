% performs matlab based image alignment



function aligndata = AlignMatlab(input_file,output_file)

% compare if structure of file names, or a single file
if isstruct(input_file)
    % set of TIF files
    reference_file = [input_file(1).path filesep input_file(1).name];
    numframes = length(input_file);
else
    % single TIF files
    reference_file = input_file;
    imginfo = imfinfo(reference_file);
    numframes = length(imginfo);
end

% setup first frame as reference
reference = imread(reference_file,1);

% setup aligner
[optimizer,metric] = imregconfig('monomodal');


% setup output file
[basedir,basename,basetype] = fileparts(output_file);
% infofile = [basedir,filesep,'info.mat'];

movingreg = uint16(zeros(size(reference,1),size(reference,2),numframes));
afftform = zeros(3,3,numframes);
R = imref2d(size(reference));


try % try parallel processor -- might not be installed
    % initialize matlab cpu clusters
    InitializeMatlabpool;

    % parallel process image registration
    if isstruct(input_file)
        % set of TIF files
        parfor i=1:numframes
            moving = imread([input_file(i).path filesep input_file(i).name],1);    
            % peform rigid body    
            % peform rigid body    di
            tform = imregtform(moving,reference,'rigid',optimizer,metric);
            movingreg(:,:,i) = imwarp(moving,R,tform,'OutputView',R);
            afftform(:,:,i) = tform.T;
        end
    else
        % single TIF files
        parfor i=1:numframes
            moving = imread(input_file,i);    
            % peform rigid body    
            % peform rigid body    di
            tform = imregtform(moving,reference,'rigid',optimizer,metric);
            movingreg(:,:,i) = imwarp(moving,R,tform,'OutputView',R);
            afftform(:,:,i) = tform.T;
        end
    end
catch
    
    if isstruct(input_file)
        % set of TIF files
        for i=1:numframes
            moving = imread([input_file(i).path filesep input_file(i).name],1);    
            % peform rigid body    
            % peform rigid body    di
            tform = imregtform(moving,reference,'rigid',optimizer,metric);
            movingreg(:,:,i) = imwarp(moving,R,tform,'OutputView',R);
            afftform(:,:,i) = tform.T;
        end
    else
        % single TIF files
        for i=1:numframes
            moving = imread(input_file,i);    
            % peform rigid body    
            % peform rigid body    di
            tform = imregtform(moving,reference,'rigid',optimizer,metric);
            movingreg(:,:,i) = imwarp(moving,R,tform,'OutputView',R);
            afftform(:,:,i) = tform.T;
        end
    end   
    
    
end





% write image file
for i=1:numframes
    imwrite(movingreg(:,:,i),output_file,'tif','WriteMode','append');
end

% write info file
aligndata.tform = afftform;
aligndata.referenceimage = reference;
% save(infofile,'aligndata');
