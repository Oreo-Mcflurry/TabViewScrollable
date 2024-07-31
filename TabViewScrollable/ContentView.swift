//
//  ContentView.swift
//  TabViewScrollable
//
//  Created by 에스지랩 on 7/31/24.
//

import SwiftUI

struct ContentView: View {
    @State private var currentTab = Tabs.one
    var offsetObserver = PageOffsetObserver()
    var body: some View {
        VStack {
            
            tabbar(.gray)
                .overlay {
                    if let collectionViewBounds = offsetObserver.collectionView?.bounds {
                        GeometryReader { proxy in
                            let padding: CGFloat = 10
                            let width = proxy.size.width
                            let tabCount = CGFloat(Tabs.allCases.count)
                            let capsulewidth = width / tabCount - padding / 2
                            let progress = offsetObserver.offset / collectionViewBounds.width
                            
                            var offset: CGFloat {
                                if currentTab == .one {
                                    return progress * capsulewidth
                                } else {
                                    return progress * capsulewidth + padding
                                }
                                
                            }
                            
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.black)
                                .frame(width: capsulewidth)
                                .offset(x: offset)
                            
                            tabbar(.white)
                                .mask(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .frame(width: capsulewidth)
                                        .offset(x: offset)
                                }
                        }
                    }
                }
                .padding(.horizontal)
            
            TabView(selection: $currentTab) {
                Color.red
                    .tag(Tabs.one)
                    .background {
                        if !offsetObserver.isObserving {
                            FindCollectionView {
                                offsetObserver.collectionView = $0
                                offsetObserver.observe()
                            }
                        }
                    }
                
                Color.yellow
                    .tag(Tabs.two)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
    @ViewBuilder func tabbar(_ tint: Color) -> some View {
        HStack(spacing: 10) {
            ForEach(Tabs.allCases, id: \.rawValue) { item in
                Button {
                    withAnimation {
                        currentTab = item
                    }
                    
                } label: {
                    Text("Test \(item.rawValue)")
                        .foregroundStyle(tint)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    //                        .background(.yellow)
                }
            }
        }
    }
    
    enum Tabs: String, CaseIterable {
        case one
        case two
    }
}

@Observable
class PageOffsetObserver: NSObject {
    var collectionView: UICollectionView?
    var offset: CGFloat = 0
    private(set) var isObserving: Bool = false
    
    deinit {
        remove()
    }
    
    func observe() {
        guard !isObserving else { return }
        collectionView?.addObserver(self, forKeyPath: "contentOffset", context: nil)
        isObserving = true
    }
    
    func remove() {
        isObserving = false
        collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset" else { return }
        if let contentOffset = (object as? UICollectionView)?.contentOffset {
            offset = contentOffset.x
        }
    }
}

struct FindCollectionView: UIViewRepresentable {
    var result: (UICollectionView) -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let collectionView = view.collectionSuperView {
                result(collectionView)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension UIView {
    var collectionSuperView: UICollectionView? {
        if let collectionView = superview as? UICollectionView {
            return collectionView
        }
        
        return superview?.collectionSuperView
    }
}

#Preview {
    ContentView()
}
