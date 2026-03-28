import SwiftUI

struct ProgressQueue: View {
    @ObservedObject var queue: ConversionQueue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Forge Queue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.foundryText)
                    
                    Text(statusSummary)
                        .font(.system(size: 12))
                        .foregroundColor(.foundryTextSecondary)
                }
                
                Spacer()
                
                // Quick actions
                HStack(spacing: 8) {
                    if queue.isProcessing {
                        Button {
                            queue.cancelAll()
                        } label: {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.bordered)
                        .tint(.foundryError)
                        .help("Cancel all jobs")
                    }
                    
                    if !queue.jobs.isEmpty {
                        Button {
                            queue.clearCompleted()
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.bordered)
                        .tint(.foundryTextSecondary)
                        .help("Clear completed jobs")
                    }
                }
            }
            
            if queue.jobs.isEmpty {
                emptyState
            } else {
                // Overall progress
                if queue.isProcessing {
                    VStack(alignment: .leading, spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.foundrySurface)
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.foundryAccent)
                                    .frame(width: geometry.size.width * queue.totalProgress, height: 8)
                            }
                        }
                        .frame(height: 8)
                        
                        HStack {
                            Text("\(queue.completedCount) forged")
                            Spacer()
                            Text("\(queue.jobs.count - queue.completedCount - queue.failedCount) remaining")
                        }
                        .font(.system(size: 11))
                        .foregroundColor(.foundryTextSecondary)
                    }
                }
                
                // Job list
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(queue.jobs) { job in
                            JobRow(job: job) {
                                if job.status == .pending || job.status == .converting {
                                    queue.cancelJob(job)
                                } else if job.status == .failed {
                                    queue.retryJob(job)
                                } else {
                                    queue.removeJob(job)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .padding(16)
        .background(Color.foundrySurface)
        .cornerRadius(12)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Conversion queue")
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 24))
                .foregroundColor(.foundryTextSecondary.opacity(0.5))
            
            Text("Forge is empty")
                .font(.system(size: 13))
                .foregroundColor(.foundryTextSecondary)
            
            Text("Drop files above to begin")
                .font(.system(size: 11))
                .foregroundColor(.foundryTextSecondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    private var statusSummary: String {
        if queue.isProcessing {
            return "\(queue.activeJobs.count) transmuting, \(queue.pendingJobs.count) waiting"
        } else if queue.jobs.isEmpty {
            return "Ready to forge"
        } else {
            return "\(queue.completedCount) completed, \(queue.failedCount) failed"
        }
    }
}

struct JobRow: View {
    let job: ConversionJob
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            Image(systemName: statusIcon)
                .font(.system(size: 14))
                .foregroundColor(statusColor)
                .frame(width: 20)
            
            // File info
            VStack(alignment: .leading, spacing: 2) {
                Text(job.inputFileName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.foundryText)
                    .lineLimit(1)
                
                Text(job.outputFormat.name)
                    .font(.system(size: 10))
                    .foregroundColor(.foundryTextSecondary)
            }
            
            Spacer()
            
            // Progress or status
            if job.status == .converting {
                ProgressView(value: job.progress)
                    .progressViewStyle(.linear)
                    .tint(.foundryAccent)
                    .frame(width: 60)
            } else {
                Text(job.status.rawValue)
                    .font(.system(size: 10))
                    .foregroundColor(statusColor)
            }
            
            // Action button
            Button(action: action) {
                Image(systemName: actionIcon)
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .foregroundColor(.foundryTextSecondary)
            .help(actionHelp)
        }
        .padding(8)
        .background(Color.foundryCard)
        .cornerRadius(6)
    }
    
    private var statusIcon: String {
        switch job.status {
        case .pending: return "clock"
        case .converting: return "flame"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .cancelled: return "stop.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch job.status {
        case .pending: return .foundryTextSecondary
        case .converting: return .foundryAccent
        case .completed: return .foundrySuccess
        case .failed: return .foundryError
        case .cancelled: return .foundryTextSecondary
        }
    }
    
    private var actionIcon: String {
        switch job.status {
        case .pending, .converting: return "xmark"
        case .failed: return "arrow.clockwise"
        default: return "trash"
        }
    }
    
    private var actionHelp: String {
        switch job.status {
        case .pending, .converting: return "Cancel job"
        case .failed: return "Retry job"
        default: return "Remove from queue"
        }
    }
}

#Preview {
    ProgressQueue(queue: ConversionQueue())
        .padding()
        .background(Color.foundryBackground)
        .frame(width: 400)
}
