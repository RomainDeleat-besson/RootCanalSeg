function [Spacing, Origin] = GetSpacingOriginFromNrrd(inputNrrd)

    fid = fopen(inputNrrd, 'rb');
    linenum = 6;
    spacing = textscan(fid,'%s',1,'delimiter','\n', 'headerlines',linenum-1);
    spacing = char(spacing{:});
    spacing = spacing(19:end);
    spacing = split(spacing,["(", ",",")"]);
    Spacing = [str2double(spacing(2)), str2double(spacing(7)), str2double(spacing(12))];
    fseek(fid,0,'bof');

    linenum = 10;
    origin = textscan(fid,'%s',1,'delimiter','\n', 'headerlines',linenum-1);
    origin = char(origin{:});    
    origin = origin(15:end);
    origin = split(origin,["(", ",",")"]);
    Origin = [str2double(origin(2)), str2double(origin(3)), str2double(origin(4))];
end