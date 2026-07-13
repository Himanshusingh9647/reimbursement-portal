import React, { useRef, useState, useCallback } from 'react';
import { Upload, File, X, Eye } from 'lucide-react';
import FilePreviewModal from './FilePreviewModal';

export default function UploadZone({
  label,
  accept = '.pdf,.jpg,.png',
  multiple = false,
  files = [],
  onFilesChange,
  required = false,
  id,
}) {
  const inputRef = useRef(null);
  const [isDragOver, setIsDragOver] = useState(false);
  const [previewFile, setPreviewFile] = useState(null);

  const handleFiles = useCallback(
    (newFiles) => {
      if (!onFilesChange) return;
      const fileList = Array.from(newFiles);
      if (multiple) {
        onFilesChange([...files, ...fileList]);
      } else {
        onFilesChange(fileList.slice(0, 1));
      }
    },
    [files, multiple, onFilesChange]
  );

  const handleDrop = useCallback(
    (e) => {
      e.preventDefault();
      setIsDragOver(false);
      if (e.dataTransfer.files.length > 0) {
        handleFiles(e.dataTransfer.files);
      }
    },
    [handleFiles]
  );

  const handleDragOver = useCallback((e) => {
    e.preventDefault();
    setIsDragOver(true);
  }, []);

  const handleDragLeave = useCallback((e) => {
    e.preventDefault();
    setIsDragOver(false);
  }, []);

  const handleClick = () => {
    inputRef.current?.click();
  };

  const handleInputChange = (e) => {
    if (e.target.files.length > 0) {
      handleFiles(e.target.files);
    }
    e.target.value = '';
  };

  const handleRemove = (index) => {
    const updated = files.filter((_, i) => i !== index);
    onFilesChange(updated);
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      handleClick();
    }
  };

  const formatSize = (bytes) => {
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  };

  return (
    <div className="flex flex-col gap-2">
      <label
        htmlFor={id}
        className="font-mono text-[10px] uppercase tracking-wide font-semibold text-gray-700 flex items-center gap-1"
      >
        {label}
        {required && <span className="text-status-rejected" aria-hidden="true">*</span>}
      </label>

      {/* Only show dropzone if empty, OR if multiple is allowed */}
      {(!files.length || multiple) && (
        <div
          className={`relative flex flex-col items-center justify-center p-3 border-2 border-dashed rounded-lg bg-gray-50 cursor-pointer focus:outline-none focus:ring-2 focus:ring-samsung-blue focus:ring-offset-2 ${
            isDragOver ? 'border-samsung-blue bg-blue-50/50' : 'border-border hover:border-gray-400 hover:bg-gray-100/50'
          } ${files.length > 0 ? 'py-3' : ''}`}
          onDrop={handleDrop}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onClick={handleClick}
          onKeyDown={handleKeyDown}
          role="button"
          tabIndex={0}
          aria-label={`${label}. Click or drag files to upload.`}
        >
          {files.length === 0 && (
            <>
              <Upload className="text-gray-400 mb-2" size={20} aria-hidden="true" />
              <p className="text-xs text-gray-700 mb-1">
                <span className="font-semibold text-samsung-blue">Click to upload</span> or drag and drop
              </p>
              <p className="font-mono text-[9px] uppercase tracking-wide text-gray-500">
                Accepted formats: {accept.replace(/\./g, '').toUpperCase().replace(/,/g, ', ')}
              </p>
            </>
          )}

          {files.length > 0 && (
            <p className="text-sm text-gray-700">
              <span className="font-semibold text-samsung-blue">Click to add more files</span> or drag and drop
            </p>
          )}
        </div>
      )}

      <input
        ref={inputRef}
        id={id}
        type="file"
        accept={accept}
        multiple={multiple}
        required={required && files.length === 0}
        className="opacity-0 w-[0.1px] h-[0.1px] absolute overflow-hidden z-[-1]"
        onChange={handleInputChange}
        aria-hidden="true"
        tabIndex={-1}
      />

      {files.length > 0 && (
        <div className="flex flex-col gap-2 mt-2" role="list" aria-label="Uploaded files">
          {files.map((file, index) => (
            <div 
              className="flex items-center justify-between p-3 border border-border rounded-md bg-white shadow-sm hover:border-blue-300 transition-colors cursor-pointer group" 
              key={`${file.name}-${index}`} 
              role="listitem"
              onClick={() => setPreviewFile(file)}
            >
              <div className="flex items-center gap-3 overflow-hidden">
                <div className="w-8 h-8 flex-shrink-0 bg-blue-50 text-samsung-blue rounded flex items-center justify-center group-hover:bg-blue-100 transition-colors">
                  <File size={16} aria-hidden="true" />
                </div>
                <div className="flex flex-col overflow-hidden">
                  <span className="text-sm font-medium text-gray-900 truncate group-hover:text-samsung-blue transition-colors" title={file.name}>{file.name}</span>
                  <span className="font-mono text-[10px] uppercase tracking-wide text-gray-500">{formatSize(file.size)}</span>
                </div>
              </div>
              <div className="flex items-center gap-1">
                <button
                  type="button"
                  className="flex-shrink-0 p-1.5 text-gray-400 hover:text-samsung-blue hover:bg-blue-50 rounded-md"
                  onClick={(e) => {
                    e.stopPropagation();
                    setPreviewFile(file);
                  }}
                  aria-label={`Preview ${file.name}`}
                >
                  <Eye size={16} />
                </button>
                <button
                  type="button"
                  className="flex-shrink-0 p-1.5 text-gray-400 hover:text-status-rejected hover:bg-red-50 rounded-md"
                  onClick={(e) => {
                    e.stopPropagation();
                    handleRemove(index);
                  }}
                  aria-label={`Remove ${file.name}`}
                >
                  <X size={16} />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {previewFile && (
        <FilePreviewModal file={previewFile} onClose={() => setPreviewFile(null)} />
      )}
    </div>
  );
}
