let processedDownloads = new Set();

chrome.downloads.onChanged.addListener(function(downloadDelta) {
  if (downloadDelta.state && downloadDelta.state.current === 'complete') {
    // Check if this download ID has already been processed
    if (processedDownloads.has(downloadDelta.id)) {
      return;
    }

    chrome.downloads.search({ id: downloadDelta.id }, function(results) {
      if (results.length > 0 && results[0].filename.endsWith('.pdf')) {
        const downloadUrl = 'file://' + results[0].filename;
        console.log('PDF download completed:', results[0]);

        // Mark this download ID as processed
        processedDownloads.add(downloadDelta.id);

        // Create a new window with the PDF
        chrome.windows.create({
          url: downloadUrl,
          type: 'popup',
          state: 'maximized'
        }, function(newWindow) {
          console.log('New full-screen window created with ID:', newWindow.id);
        });
      }
    });
  }
});
