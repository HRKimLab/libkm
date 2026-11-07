% source folder
fdir = 'E:/family_photos/';
% destination folder
out_dir = 'C:/Users/user/Downloads/video_clips/';
% ffmpeg program used for clipping
ffmpeg = 'C:/Misc/ffmpeg/bin/ffmpeg.exe';

%%
% search mp4 files in the source folder
finfo = dir([fdir '*.mp4']);

% iterate files in the source folder, generate clipped videos in the
% destination folder
for iF = 1:numel(finfo)
   fpath =  [fdir finfo(iF).name];
   cmd = [ffmpeg ' -i ' fpath ' -ss 0 -t 30 ' out_dir finfo(iF).name]
   system(cmd);
end