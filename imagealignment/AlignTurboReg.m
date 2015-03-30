% performs imagej turboreg image alignment



function aligndata = AlignTurboReg(input_file, output_file )

% import Miji and imagej library
StartMiji;
import ij.*

% open file in imagej
MIJ.run('Open...', ['path=[' input_file ']']);

% prep for registration with first image
MIJ.run('Turboreg prep');
keyboard
aligndata.referenceimage = MIJ.getImage('reference');
keyboard
MIJ.run('Turboreg register');


% grab Transform data and close
aligndata.tform = MIJ.getResultsTable;
IJ.selectWindow('Results');
MIJ.run('Close')



% format tformdata into consistent matrix


% save aligned data
IJ.selectWindow('finished');
MIJ.run('8-bit');
IJ.saveAs('Tiff',output_file)
MIJ.run('Close');
end

